#Requires -Version 5.1

<#
.SYNOPSIS
    Terminal Intelligence PowerShell Profile Setup Script

.DESCRIPTION
    This script automatically adds functions and aliases to your PowerShell profile
    for each commander defined in languages.csv. It allows you to call custom
    Ollama models running in WSL from Windows PowerShell terminals.

.EXAMPLE
    .\Setup-PowerShellProfile.ps1
    
    Adds functions and aliases for all commanders in languages.csv

.NOTES
    - Safe to run multiple times (idempotent)
    - Only adds new commanders if languages.csv is updated
    - Creates backup of profile before making changes
    - Automatically reloads profile after updates
#>

[CmdletBinding()]
param()

# Color output functions
function Write-StatusInfo($Message) {
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-StatusSuccess($Message) {
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-StatusWarning($Message) {
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-StatusError($Message) {
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-StatusHeader($Message) {
    Write-Host ""
    Write-Host "===========================================" -ForegroundColor Blue
    Write-Host " $Message" -ForegroundColor Blue
    Write-Host "===========================================" -ForegroundColor Blue
    Write-Host ""
}

# Function to check if WSL is available
function Test-WSLAvailability {
    try {
        $wslResult = wsl --status 2>$null
        return $true
    }
    catch {
        return $false
    }
}

# Function to generate PowerShell function name from language
function Get-FunctionName($Language) {
    $cleanLanguage = $Language -replace '[^a-zA-Z0-9]', ''
    return "Invoke-$cleanLanguage-Commander"
}

# Function to generate alias name from filename
function Get-AliasName($Filename) {
    $baseName = $Filename -replace '-commander$', ''
    if ($baseName.Length -ge 2) {
        return "o" + $baseName.Substring(0, 2).ToLower()
    }
    else {
        return "o" + $baseName.ToLower()
    }
}

# Function to check if function exists in profile
function Test-FunctionInProfile($FunctionName, $ProfileContent) {
    return $ProfileContent -match "function\s+$([regex]::Escape($FunctionName))\s*\{"
}

# Function to check if alias exists in profile
function Test-AliasInProfile($AliasName, $ProfileContent) {
    return $ProfileContent -match "Set-Alias\s+-Name\s+$([regex]::Escape($AliasName))\s+"
}

# Main execution
Write-StatusHeader "Terminal Intelligence PowerShell Profile Setup"

# Check prerequisites
Write-StatusHeader "Step 1: Checking Prerequisites"

# Check if languages.csv exists
$csvPath = Join-Path $PSScriptRoot "languages.csv"
if (-not (Test-Path $csvPath)) {
    Write-StatusError "languages.csv not found in script directory: $PSScriptRoot"
    exit 1
}
Write-StatusSuccess "Found languages.csv"

# Check WSL availability
Write-StatusInfo "Checking WSL availability..."
if (-not (Test-WSLAvailability)) {
    Write-StatusError "WSL is not available or not properly configured!"
    Write-StatusError "Please ensure WSL is installed and configured."
    exit 1
}
Write-StatusSuccess "WSL is available"

# Check PowerShell profile path
Write-StatusInfo "PowerShell profile path: $PROFILE"
$profileDir = Split-Path $PROFILE -Parent
if (-not (Test-Path $profileDir)) {
    Write-StatusWarning "Profile directory doesn't exist. Creating: $profileDir"
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

# Create profile if it doesn't exist
if (-not (Test-Path $PROFILE)) {
    Write-StatusWarning "PowerShell profile doesn't exist. Creating: $PROFILE"
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
}
Write-StatusSuccess "PowerShell profile is ready"

# Step 2: Read and process CSV
Write-StatusHeader "Step 2: Processing Languages CSV"

try {
    $commanders = Import-Csv $csvPath
    Write-StatusSuccess "Loaded $($commanders.Count) commanders from CSV"
}
catch {
    Write-StatusError "Failed to read languages.csv: $($_.Exception.Message)"
    exit 1
}

# Step 3: Analyze current profile
Write-StatusHeader "Step 3: Analyzing Current Profile"

$currentProfileContent = ""
if (Test-Path $PROFILE) {
    $currentProfileContent = Get-Content $PROFILE -Raw
}

$existingCommanders = @()
$newCommanders = @()

foreach ($commander in $commanders) {
    $functionName = Get-FunctionName $commander.language
    $aliasName = Get-AliasName $commander.filename
    
    $functionExists = Test-FunctionInProfile $functionName $currentProfileContent
    $aliasExists = Test-AliasInProfile $aliasName $currentProfileContent
    
    if ($functionExists -and $aliasExists) {
        Write-StatusSuccess "Found existing: $aliasName -> $functionName ($($commander.language))"
        $existingCommanders += $commander
    }
    else {
        Write-StatusWarning "Missing: $aliasName -> $functionName ($($commander.language))"
        $newCommanders += $commander
    }
}

if ($newCommanders.Count -eq 0) {
    Write-StatusSuccess "All commanders already exist in profile! ($($existingCommanders.Count) commanders)"
    Write-StatusInfo "Profile is up to date. No changes needed."
    exit 0
}

# Step 4: Backup and update profile
Write-StatusHeader "Step 4: Updating PowerShell Profile"

# Create backup
$backupPath = "$PROFILE.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
if (Test-Path $PROFILE) {
    Copy-Item $PROFILE $backupPath
    Write-StatusSuccess "Backup created: $backupPath"
}

# Prepare new content
$newContent = @()

# Add header comment for new commanders
$newContent += ""
$newContent += "# Terminal Intelligence Commanders - Added $(Get-Date)"

foreach ($commander in $newCommanders) {
    $functionName = Get-FunctionName $commander.language
    $aliasName = Get-AliasName $commander.filename
    
    Write-StatusInfo "Adding: $aliasName -> $functionName ($($commander.language))"
    
    # Add function
    $newContent += ""
    $newContent += "function $functionName {"
    $newContent += "    param("
    $newContent += "        [Parameter(ValueFromRemainingArguments=`$true)]"
    $newContent += "        [string[]]`$Arguments"
    $newContent += "    )"
    $newContent += "    wsl ollama run $($commander.filename) `$Arguments"
    $newContent += "}"
    
    # Add alias
    $newContent += "Set-Alias -Name $aliasName -Value $functionName"
}

$newContent += ""
$newContent += "# End of Terminal Intelligence Commanders"

# Append to profile
$newContent | Add-Content -Path $PROFILE -Encoding UTF8

Write-StatusSuccess "Added $($newCommanders.Count) new commanders to profile"

# Step 5: Add base ollama alias if not exists
Write-StatusHeader "Step 5: Checking Base Ollama Alias"

if (-not (Test-AliasInProfile "oll" $currentProfileContent)) {
    Write-StatusInfo "Adding base ollama alias 'oll'..."
    
    $ollContent = @()
    $ollContent += ""
    $ollContent += "# Base Ollama Function"
    $ollContent += "function Invoke-Ollama {"
    $ollContent += "    param("
    $ollContent += "        [Parameter(ValueFromRemainingArguments=`$true)]"
    $ollContent += "        [string[]]`$Arguments"
    $ollContent += "    )"
    $ollContent += "    wsl ollama run gemma3:12b `$Arguments"
    $ollContent += "}"
    $ollContent += "Set-Alias -Name oll -Value Invoke-Ollama"
    
    $ollContent | Add-Content -Path $PROFILE -Encoding UTF8
    Write-StatusSuccess "Added base ollama alias 'oll'"
}
else {
    Write-StatusSuccess "Base ollama alias 'oll' already exists"
}

# Step 6: Reload profile
Write-StatusHeader "Step 6: Reloading Profile"

try {
    . $PROFILE
    Write-StatusSuccess "PowerShell profile reloaded successfully"
}
catch {
    Write-StatusWarning "Profile reload failed: $($_.Exception.Message)"
    Write-StatusInfo "Please restart PowerShell or run: . `$PROFILE"
}

# Final summary
Write-StatusHeader "Setup Complete!"

$totalCommanders = $existingCommanders.Count + $newCommanders.Count
Write-Host "✓ " -ForegroundColor Green -NoNewline
Write-Host "Commander functions: $totalCommanders functions available"

Write-Host "✓ " -ForegroundColor Green -NoNewline  
Write-Host "Commander aliases: $totalCommanders aliases configured"

Write-Host "✓ " -ForegroundColor Green -NoNewline
Write-Host "Base ollama alias: 'oll' available"

Write-Host "✓ " -ForegroundColor Green -NoNewline
Write-Host "PowerShell profile updated and reloaded"

if ($newCommanders.Count -gt 0) {
    Write-StatusSuccess "Added $($newCommanders.Count) new commanders!"
    Write-Host "  → " -ForegroundColor Blue -NoNewline
    Write-Host "New aliases: " -NoNewline
    $newAliases = $newCommanders | ForEach-Object { Get-AliasName $_.filename }
    Write-Host ($newAliases -join ", ") -ForegroundColor Yellow
}
else {
    Write-StatusSuccess "All commanders were already configured!"
}

Write-StatusInfo "Available aliases: " -NoNewline
$allAliases = $commanders | ForEach-Object { Get-AliasName $_.filename }
$allAliases += "oll"
Write-Host ($allAliases -join ", ") -ForegroundColor Yellow

Write-StatusInfo "Example usage: ops 'create a PowerShell script to list files'"
Write-StatusInfo ""
Write-StatusInfo "💡 Tip: Add new languages to languages.csv and run this script again!"

Write-Host ""
Write-Host "Happy coding! 🚀" -ForegroundColor Blue

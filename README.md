# Terminal Intelligence 🚀

A comprehensive automation framework for generating language-specific AI command assistants using Ollama models with custom system prompts. Terminal Intelligence allows you to create specialized AI commanders for different programming languages and seamlessly integrate them into both Linux and Windows environments.

## 📋 Table of Contents

- [Overview](#-overview)
- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [Project Structure](#-project-structure)
- [Configuration](#️-configuration)
- [Usage](#-usage)
- [Cross-Platform Support](#-cross-platform-support)
- [Scripts Reference](#-scripts-reference)
- [Examples](#-examples)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)

## 🎯 Overview

Terminal Intelligence transforms your terminal experience by providing intelligent, context-aware AI assistants for different programming languages. Each "commander" is a specialized AI model trained with language-specific system prompts, making them experts in their respective domains.

**What makes Terminal Intelligence special:**

- 🎨 **Language-Specific Expertise**: Each commander specializes in a specific programming language
- 🔄 **Cross-Platform Compatibility**: Works seamlessly on Linux and Windows (via WSL)
- ⚡ **One-Command Setup**: Automated scripts handle the entire setup process
- 🔧 **Idempotent Operations**: Safe to run multiple times without conflicts
- 📈 **Extensible**: Easy to add new languages and commanders

## ✨ Features

### Core Features

- **🤖 Automated Model Generation**: Creates Ollama models with custom system prompts
- **🎯 Language-Specific Commanders**: Specialized AI assistants for Python, JavaScript, PowerShell, Bash, TypeScript, and more
- **⚡ Smart Aliases**: Easy-to-remember shortcuts (`opy`, `ojs`, `ops`, etc.)
- **🔄 Incremental Updates**: Add new languages without affecting existing setup
- **💾 Backup & Recovery**: Automatic backups before making changes

### Platform Support

- **🐧 Linux**: Native bash integration with automatic `.bashrc` configuration
- **🪟 Windows**: PowerShell profile integration with WSL backend
- **🔀 Cross-Platform**: Consistent experience across operating systems

### Developer Experience

- **📊 Rich Feedback**: Colored output with detailed progress reporting
- **🛡️ Error Handling**: Comprehensive validation and error recovery
- **📖 Self-Documenting**: Clear help messages and usage examples

## 🔧 Prerequisites

### Linux Environment

- **Ollama**: Installed and running
- **Bash**: Version 4.0 or higher
- **Standard Unix Tools**: `sed`, `cut`, `grep`, `tail`

### Windows Environment

- **PowerShell**: Version 5.1 or higher
- **WSL**: Windows Subsystem for Linux configured
- **Ollama**: Installed in WSL environment

### Common Requirements

- **Base Model**: `gemma3:12b` model available in Ollama
- **Permissions**: Ability to modify profile files (`.bashrc` or PowerShell profile)

## 🚀 Quick Start

### Linux Setup

1. **Clone and Navigate**

   ```bash
   cd Terminal-Intelligence
   chmod +x *.sh
   ```

2. **Run Complete Setup**

   ```bash
   ./linux_TI.sh
   ```

3. **Start Using Commanders**

   ```bash
   opy "write a function to calculate file hash"
   ojs "create a simple form validation function"
   ops "get Windows version and build number"
   ```

### Windows Setup

1. **Open PowerShell as Administrator**

   ```powershell
   Set-Location "d:\Terminal-Intelligence"
   ```

2. **Run Setup Script**

   ```powershell
   .\Setup-PowerShellProfile.ps1
   ```

3. **Start Using Commanders**

   ```powershell
   opy "create a python script for data analysis"
   ojs "build a React component for user authentication"
   ```

## 📁 Project Structure

```plaintext
Terminal-Intelligence/
├── 📄 README.md                    # Project documentation
├── 📊 languages.csv               # Language configuration file
├── 🔧 generate_commander.sh       # Core model generation script
├── 📦 batch_generate.sh           # Batch processing for all languages
├── 🔗 create_aliases.sh           # Linux alias management
├── 🚀 linux_TI.sh                # Complete Linux setup automation
├── 💻 Setup-PowerShellProfile.ps1 # Windows PowerShell setup
└── 📋 Generated Files/
    ├── py-commander               # Python specialist model
    ├── js-commander               # JavaScript specialist model
    ├── ps-commander               # PowerShell specialist model
    ├── sh-commander               # Bash specialist model
    └── ts-commander               # TypeScript specialist model
```

## ⚙️ Configuration

### Languages Configuration (`languages.csv`)

The heart of Terminal Intelligence is the `languages.csv` file that defines available commanders:

```csv
language,filename
Python,py-commander
JavaScript,js-commander
PowerShell,ps-commander
Bash,sh-commander
TypeScript,ts-commander
```

**Adding New Languages:**

1. Add a new row to `languages.csv`
2. Run the setup script again
3. New commanders will be automatically created

**Example - Adding Go:**

```csv
language,filename
Python,py-commander
JavaScript,js-commander
PowerShell,ps-commander
Bash,sh-commander
TypeScript,ts-commander
Go,go-commander
```

### Alias Naming Convention

Aliases follow a consistent pattern:

- **Format**: `o` + first 2 letters of commander filename
- **Examples**:
  - `py-commander` → `opy`
  - `js-commander` → `ojs`
  - `ps-commander` → `ops`
  - `sh-commander` → `osh`
  - `ts-commander` → `ots`

### Special Aliases

- **`oll`**: Direct access to base `gemma3:12b` model without custom prompts

## 💡 Usage

### Basic Command Structure

```bash
# Linux/WSL
<alias> "<your request>"

# Windows PowerShell
<alias> "<your request>"
```

### Real-World Examples

#### Python Development

```bash
opy "create a function to read CSV files with pandas"
opy "write a script to rename files in bulk"
opy "generate a simple HTTP server with one endpoint"
opy "create a class for database connection handling"
```

#### JavaScript Development

```bash
ojs "write a function to validate email addresses"
ojs "create a simple Express route handler"
ojs "generate code to fetch data from an API"
ojs "write a function to sort array of objects by property"
```

#### PowerShell Administration

```bash
ops "create a new virtual volume using a VHDX file"
ops "get all running services and export to CSV"
ops "add current user to a specific Windows group"
ops "create a scheduled task to run daily at 3 AM"
```

#### Bash Scripting

```bash
osh "add the current user to the docker user group"
osh "create a simple backup script for home directory"
osh "write a one-liner to find large files over 100MB"
osh "generate a script to check disk space and send alert"
```

#### General AI Queries

```bash
oll "explain the difference between grep and awk"
oll "what are the basic Git commands I should know"
```

## 🌐 Cross-Platform Support

### Linux Integration

- **Native Bash**: Direct integration with `.bashrc`
- **System Integration**: Commands work in any terminal
- **Performance**: Optimal performance with local Ollama

### Windows Integration

- **PowerShell Functions**: Rich PowerShell function integration
- **WSL Backend**: Leverages Linux Ollama installation
- **Profile Management**: Automatic PowerShell profile updates

### Consistent Experience

Both platforms provide:

- ✅ Same command aliases
- ✅ Identical functionality
- ✅ Seamless model sharing
- ✅ Cross-platform file compatibility

## 📚 Scripts Reference

### Core Scripts

#### `generate_commander.sh`

**Purpose**: Creates individual commander models

```bash
./generate_commander.sh "<language>" "<filename>"
```

**Example**: `./generate_commander.sh "Python" "py-commander"`

#### `batch_generate.sh`

**Purpose**: Processes all languages from CSV

```bash
./batch_generate.sh [csv_file]
```

#### `create_aliases.sh`

**Purpose**: Manages Linux bash aliases

```bash
./create_aliases.sh [csv_file]
```

#### `linux_TI.sh`

**Purpose**: Complete Linux environment setup

```bash
./linux_TI.sh
```

#### `Setup-PowerShellProfile.ps1`

**Purpose**: Windows PowerShell environment setup

```powershell
.\Setup-PowerShellProfile.ps1
```

### Script Features

| Feature | Linux Scripts | PowerShell Script |
|---------|--------------|------------------|
| Idempotent | ✅ | ✅ |
| Backup Creation | ✅ | ✅ |
| Progress Reporting | ✅ | ✅ |
| Error Handling | ✅ | ✅ |
| Incremental Updates | ✅ | ✅ |

## 🎨 Examples

### Single Command Help

#### Python Quick Tasks

```bash
opy "how to check if a file exists"
opy "command to install packages from requirements.txt"
opy "create a simple list comprehension to filter even numbers"
opy "one-liner to get current timestamp"
```

#### JavaScript Quick Solutions

```bash
ojs "how to remove duplicates from an array"
ojs "command to start a basic HTTP server"
ojs "simple function to check if object is empty"
ojs "how to convert string to title case"
```

#### PowerShell System Tasks

```bash
ops "add current user to docker group"
ops "create virtual volume using VHDX file"
ops "command to check Windows build version"
ops "how to restart a specific service"
```

#### Bash Terminal Operations

```bash
osh "find all files larger than 100MB"
osh "command to add user to sudo group"
osh "one-liner to backup a directory with timestamp"
osh "how to check if port 80 is open"
```

#### General Command Help

```bash
oll "git command to undo last commit"
oll "difference between chmod 755 and 644"
oll "how to check disk space in Linux"
```

### Simple Script Blocks

#### Quick Automation Tasks

```bash
opy "create a script to count lines in all Python files"
ojs "write a function to validate email format"
ops "script to list all installed programs"
osh "create a backup script with date suffix"
```

#### System Configuration

```bash
ops "add current user to docker group PowerShell"
osh "add current user to docker group bash"
opy "script to set up Python virtual environment"
ojs "create package.json for new Node.js project"
```

### Learning and Quick Reference

```bash
# Command syntax examples
opy "show me Python list comprehension syntax with example"
ojs "how to use array map method in JavaScript"
ops "PowerShell pipeline examples with Where-Object"
osh "common awk patterns for text processing"

# Quick troubleshooting
oll "why is my SSH connection timing out"
oll "common Git merge conflict resolution steps"
```

## 🔧 Troubleshooting

### Common Issues

#### Ollama Not Found

**Problem**: `ollama: command not found`
**Solution**:

```bash
# Install Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# Verify installation
ollama --version
```

#### WSL Issues (Windows)

**Problem**: WSL commands fail
**Solution**:

```powershell
# Enable WSL
wsl --install

# Check WSL status
wsl --status
```

#### Permission Denied

**Problem**: Cannot execute scripts
**Solution**:

```bash
# Linux
chmod +x *.sh

# PowerShell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### Model Creation Fails

**Problem**: Ollama model creation errors
**Solution**:

```bash
# Check Ollama service
ollama list

# Restart Ollama if needed
sudo systemctl restart ollama
```

### Debug Mode

Enable detailed logging for troubleshooting:

```bash
# Linux
bash -x ./linux_TI.sh

# Check logs
journalctl -u ollama
```

### Cleanup and Reset

If you need to start fresh:

```bash
# Remove all commander models
ollama list | grep commander | awk '{print $1}' | xargs -I {} ollama rm {}

# Remove aliases (backup .bashrc first!)
# Edit ~/.bashrc manually to remove Terminal Intelligence section

# Re-run setup
./linux_TI.sh
```

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### Adding New Languages

1. **Update Configuration**

   ```csv
   # Add to languages.csv
   NewLanguage,new-commander
   ```

2. **Test Integration**

   ```bash
   ./linux_TI.sh  # Linux
   .\Setup-PowerShellProfile.ps1  # Windows
   ```

3. **Validate Functionality**

   ```bash
   one "test the new commander"  # 'one' = 'o' + 'ne' (first 2 letters)
   ```

### Improving Scripts

- **Error Handling**: Enhance validation and error recovery
- **Performance**: Optimize script execution time
- **Features**: Add new capabilities and options
- **Documentation**: Improve clarity and examples

### Testing

Before submitting changes:

1. **Test on Clean Environment**
2. **Verify Cross-Platform Compatibility**
3. **Check Idempotent Behavior**
4. **Validate Error Scenarios**

### Contribution Guidelines

- 📝 **Clear Commit Messages**: Describe changes clearly
- 🧪 **Test Thoroughly**: Ensure changes work on both platforms
- 📖 **Update Documentation**: Keep README.md current
- 🎯 **Follow Conventions**: Maintain coding style consistency

---

## 📞 Support

- **Issues**: Report bugs and feature requests
- **Discussions**: Share ideas and get help
- **Documentation**: Contribute to project documentation

---

### **Happy Coding with Terminal Intelligence! 🚀**

*Transform your terminal into an intelligent development companion.*

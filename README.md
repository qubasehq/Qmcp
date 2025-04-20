# Qubase MCP

A powerful, cross-platform AI Chat Client implementing the Model Context Protocol (MCP) for seamless AI interactions.

---

## Overview

Qubase MCP is a sophisticated chat interface that revolutionizes AI interactions on desktop and mobile devices. Built with Flutter and implementing the Model Context Protocol, it provides a unified interface for multiple Large Language Models (LLMs) while ensuring secure, efficient, and context-aware conversations.

## Features

### Core Capabilities

| Feature | Description |
|---------|-------------|
| Universal Compatibility | Works seamlessly across all major platforms |
| Model Flexibility | Connect to any supported LLM without changing workflow |
| Context Awareness | Leverages MCP for maintaining conversation context |
| Enterprise Ready | Built with security and scalability in mind |

### Platform Support

| Platform | Status |
|----------|---------|
| Desktop (macOS, Windows, Linux) | Available |
| Mobile (iOS, Android) | Available |
| Web | Coming Soon |

### Supported AI Models

- OpenAI (GPT-3.5, GPT-4)
- Anthropic Claude
- OLLama (Local Models)
- DeepSeek
- Custom Model Support

---

## Local LLM Setup

### Android Setup

1. **Install Termux**
   - Download Termux ARM64 V8 from [Termux GitHub](https://github.com/termux/termux-app/releases)
   - Install and open Termux
   - Run `termux-setup-storage` to grant storage permissions
   - Run `termux-change-repo` to select package mirror
   - Update with `pkg upgrade`

2. **Required Packages**
   ```bash
   # Install Tur repository
   pkg install tur-repo
   
   # Install Ollama and Zellij
   pkg install ollama
   pkg install zellij
   ```

3. **Android Configuration**
   - Enable Developer Options: Settings > About device > Tap "Build number" 7 times
   - In Developer options, enable "Disable child process restrictions"

4. **Model Operations**
   ```bash
   # Start Ollama server
   ollama serve
   
   # In a new terminal, run models:
   ollama run deepseek-r1.5b  # For DeepSeek
   ollama run llama3.2        # For Llama3
   ```

5. **Control Commands**

   | Action | Command |
   |--------|---------|
   | Stop output | `CTRL + C` |
   | Exit model | `CTRL + D` |
   | Clear screen | `CTRL + L` |
   | Stop server | `ps aux \| grep ollama` then `kill [PID]` |

### Desktop Setup
_Coming soon..._

---

## System Requirements

### Hardware Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| RAM | 4GB | 8GB |
| Storage | 2GB free | 4GB free |
| Processor | Intel/AMD x64 or ARM64 | Modern multi-core |

### Software Requirements

| Component | Version |
|-----------|---------|
| Windows | 10 or later |
| macOS | 10.15 or later |
| Ubuntu | 20.04 or later |
| Flutter SDK | 3.0 or later |
| Git | Latest stable |

---

## Installation Guide

### Prerequisites

1. **Flutter Setup**
   ```bash
   git clone https://github.com/flutter/flutter.git
   export PATH="$PATH:`pwd`/flutter/bin"
   flutter doctor
   ```

2. **System Dependencies**
   ```bash
   # Linux
   sudo apt-get update
   sudo apt-get install libsqlite3-0 libsqlite3-dev

   # macOS
   brew install sqlite3

   # Windows
   # SQLite included in Flutter Windows setup
   ```

3. **Development Tools**
   ```bash
   # Using uv (Recommended)
   brew install uv

   # Alternative: npm
   brew install node
   ```

### Application Setup

1. **Installation**
   ```bash
   git clone https://github.com/qubasehq/Qmcp.git
   cd Qmcp
   flutter pub get
   ```

2. **Launch**
   ```bash
   # Desktop platforms
   flutter run -d <platform>  # macos, windows, linux

   # Mobile development
   flutter run -d <device-id>
   ```

---

## Configuration

### Initial Setup

1. **API Configuration**
   - Launch Qubase MCP
   - Navigate to Settings > API Configuration
   - Enter LLM API credentials
   - Configure custom endpoints (if needed)

2. **MCP Server Setup**
   - Access Settings > MCP Server
   - Choose installation method
   - Configure server settings
   - Select default AI model

### File Locations

| Purpose | Path |
|---------|------|
| Configuration | `~/Library/Application Support/qubase_mcp/mcp_server.json` |
| Logs | `~/Library/Application Support/run.daodao.qubase_mcp/logs` |
| Application Data | `~/Library/Application Support/qubase_mcp` |

### Reset Application
```bash
# Clear all data (use with caution)
rm -rf ~/Library/Application\ Support/run.daodao.qubase_mcp
rm -rf ~/Library/Application\ Support/qubase_mcp
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Connection Issues | Verify API keys and network connectivity |
| Performance Problems | Check system resources and clear cache |
| Model Errors | Validate model configurations and quotas |

For additional support, visit our [Issues](https://github.com/qubasehq/Qmcp/issues) page.

---

## Development Roadmap

### Upcoming Features

| Feature | Description |
|---------|-------------|
| MCP Server Marketplace | Easy discovery and deployment of community servers |
| Enhanced Integration | Automated server setup and cloud sync support |
| RAG Implementation | Document processing and knowledge base integration |
| UI/UX Improvements | Custom themes, keyboard shortcuts, mobile optimization |

---

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to your branch
5. Open a Pull Request

---

## Acknowledgments

- Model Context Protocol (MCP) Team
- MCP CLI Contributors
- Flutter Community
- Open Source AI Community

---

## License

Licensed under Apache License 2.0 - see the [LICENSE](./LICENSE) file for details.


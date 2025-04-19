# Qubase MCP

> A powerful, cross-platform AI Chat Client implementing the Model Context Protocol (MCP) for seamless AI interactions

## 📖 Overview

Qubase MCP is a sophisticated chat interface that revolutionizes AI interactions on desktop and mobile devices. Built with Flutter and implementing the Model Context Protocol, it provides a unified interface for multiple Large Language Models (LLMs) while ensuring secure, efficient, and context-aware conversations.

## 🎯 Why Qubase MCP?

- **Universal Compatibility**: Works seamlessly across all major platforms
- **Model Flexibility**: Connect to any supported LLM without changing your workflow
- **Context Awareness**: Leverages MCP for maintaining conversation context
- **Enterprise Ready**: Built with security and scalability in mind

## 🚀 Key Features

### Platform Support
- 🖥️ Desktop: macOS, Windows, Linux
- 📱 Mobile: iOS, Android
- 🌐 Web: Coming Soon

### AI Model Integration
- ✨ OpenAI (GPT-3.5, GPT-4)
- 🎯 Anthropic Claude
- 🚀 OLLama (Local Models)
- 🔮 DeepSeek
- 📚 Custom Model Support

### Smart Features
- 🧠 Intelligent Context Management
- 🔄 Real-time Streaming with SSE
- 📝 Rich Text Conversation History
- 🎨 Customizable Themes (Dark/Light)
- 🔒 Secure Data Handling
- 📊 Usage Analytics
- 🔍 Advanced Search Capabilities

## 💻 System Requirements

- **Operating System**:
  - Windows 10 or later
  - macOS 10.15 or later
  - Ubuntu 20.04 or later
- **Hardware**:
  - 4GB RAM minimum (8GB recommended)
  - 2GB free disk space
  - Intel/AMD x64 or ARM64 processor
- **Software**:
  - Flutter SDK 3.0 or later
  - Git
  - Internet connection for cloud models

## 🛠️ Setup Guide

### Prerequisites Installation

1. **Flutter Setup**:
   ```bash
   # Download Flutter SDK
   git clone https://github.com/flutter/flutter.git
   export PATH="$PATH:`pwd`/flutter/bin"
   flutter doctor
   ```

2. **System Dependencies**:
   ```bash
   # For Linux
   sudo apt-get update
   sudo apt-get install libsqlite3-0 libsqlite3-dev

   # For macOS
   brew install sqlite3

   # For Windows
   # SQLite is included in Flutter Windows setup
   ```

3. **Development Tools**:
   ```bash
   # Using uv (Recommended)
   brew install uv

   # OR using npm
   brew install node
   ```

### Application Setup

1. **Clone and Configure**:
   ```bash
   git clone https://github.com/qubasehq/Qmcp.git
   cd Qmcp
   flutter pub get
   ```

2. **Launch Application**:
   ```bash
   # For desktop platforms
   flutter run -d <platform>  # macos, windows, linux

   # For mobile development
   flutter run -d <device-id>
   ```

## 📱 Getting Started

### Initial Configuration

1. **API Setup**:
   - Launch Qubase MCP
   - Navigate to Settings > API Configuration
   - Enter your LLM API credentials
   - Configure custom endpoints (if needed)

2. **MCP Server Configuration**:
   - Go to Settings > MCP Server
   - Choose installation method
   - Configure server settings
   - Select default AI model

3. **Start Using**:
   - Create a new chat
   - Select your preferred model
   - Begin your AI conversation

## 🔧 Advanced Configuration

### File Locations
```bash
# Configuration
~/Library/Application Support/qubase_mcp/mcp_server.json

# Logs
~/Library/Application Support/run.daodao.qubase_mcp/logs

# Application Data
~/Library/Application Support/qubase_mcp
```

### Reset Application
```bash
# Clear all data (use with caution)
rm -rf ~/Library/Application\ Support/run.daodao.qubase_mcp
rm -rf ~/Library/Application\ Support/qubase_mcp
```

## 🔍 Troubleshooting

- **Connection Issues**: Verify API keys and network connectivity
- **Performance Problems**: Check system resources and clear cache
- **Model Errors**: Validate model configurations and quotas
- **For more help**: Visit our [Issues](https://github.com/qubasehq/Qmcp/issues) page

## 🎯 Roadmap

- 📚 **MCP Server Marketplace**
  - Easy discovery of community servers
  - One-click deployment
  
- 🤝 **Enhanced Integration**
  - Automated server setup
  - Cloud sync support
  
- 🎯 **RAG Implementation**
  - Document processing
  - Knowledge base integration
  
- 🎨 **UI/UX Improvements**
  - Custom themes
  - Keyboard shortcuts
  - Mobile optimization

## 👥 Contributing

We welcome contributions! Here's how you can help:

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to your branch
5. Open a Pull Request

## 🤝 Acknowledgments

Built with gratitude to:
- Model Context Protocol (MCP) Team
- MCP CLI Contributors
- Flutter Community
- Open Source AI Community

## 📄 License

Licensed under Apache License 2.0 - see the [LICENSE](./LICENSE) file for details.


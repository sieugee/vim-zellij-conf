
🚀 Vim & Zellij Terminal Configuration

This repository provides an automated installation and configuration setup for **Vim 9.1** and **Zellij** to create an amazing terminal development experience. Get a powerful, modern terminal setup with just one command!

---

## 📦 What's Included

- **Vim 9.1** - Latest version compiled from source with enhanced features
- **Zellij** - Modern terminal multiplexer with intuitive layouts
- **Pre-configured settings** - Optimized configurations for both tools
- **Essential plugins** - Vim plugins for enhanced productivity
- **Search tools** - Ripgrep and fd-find for fast file searching

---

## 🎯 Quick Installation

Get everything set up instantly with this one-liner:

```bash
bash <(curl -L https://raw.githubusercontent.com/sieugee/vim-zellij-conf/master/install.sh)
```
**Notice**: You may need to input your password for sudo command during installation.

### What happens during installation:
- ✅ Downloads and compiles Vim 9.1 from source
- ✅ Installs Zellij terminal multiplexer
- ✅ Sets up vim-plug plugin manager
- ✅ Installs ripgrep and fd-find for searching
- ✅ Applies optimized configurations
- ✅ Installs essential Vim plugins

---

## 🛠️ Development & Testing

### Prerequisites
- UNIX system and bash shell
- curl and git installed
- sudo privileges

### Local Development Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/sieugee/vim-zellij-conf.git
   cd vim-zellij-conf
   ```

2. **Test with local configurations:**
   ```bash
   ./install.sh --test
   ```

3. **Make the script executable (if needed):**
   ```bash
   chmod +x install.sh
   ```

### 📁 Repository Structure
```
vim-zellij-conf/
├── install.sh           # Main installation script
├── vimrc/
│   └── .vimrc          # Vim configuration file
├── zellij/
│   └── config.kdl      # Zellij configuration file
└── README.md           # This file
```

### 🔧 Development Notes
- Use `--test` flag to install from local configuration files instead of downloading from GitHub
- The script automatically handles dependencies and permissions
- All configurations are stored in the respective directories for easy modification

---

## 📋 Features

### Vim Configuration
- 🎨 Modern color scheme and UI enhancements
- 📝 Essential plugins via vim-plug
- 🔍 Integrated search with ripgrep and fd-find
- ⚡ Performance optimizations
- 🎯 Developer-friendly key mappings
- 🌳 Fast and lightweight tree viewer
- 🔀 Git integration
- 🤖 Copilot Chat support

### Zellij Configuration
- 🖥️ Intuitive terminal multiplexing
- 📱 Responsive layout management
- 🎨 Clean and modern interface
- ⌨️ Efficient keybindings
- 🔄 Session persistence

---

## 🤝 Contributing

Feel free to submit issues, fork the repository, and create pull requests for any improvements.

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

**Happy coding! 🎉**

#!/bin/bash
set -e

# Global variable
test_context=false
SCRIPT_DIR=$(dirname "$0")

# Function to parse command line arguments
parse_args() {
    for arg in "$@"; do
        case $arg in
            --test)
                test_context=true
                echo "Test mode enabled - config from local script"
                shift
                ;;
            *)
                # Unknown option
                ;;
        esac
    done
}

# Function to check if vim 9 is already installed
check_vim_version() {
    if command -v vim >/dev/null 2>&1; then
        local version_output=$(vim --version 2>/dev/null | head -n1)
        if [[ "$version_output" == *"Vi IMproved 9"* ]]; then
            echo "Vim 9 is already installed: $version_output"
            return 0
        fi
    fi
    return 1
}

# Install vim 9.1
download_and_install_vim() {
    if ! check_vim_version; then
        echo =============Installing VIM9.1=====================
        sudo apt update
        sudo apt install -y  build-essential libncurses5-dev

        cd /tmp
        rm -rf vim*
        curl -L https://www.vim.org/downloads/vim-9.1.tar.bz2 -o vim-9.1.tar.bz2
        tar -xjf vim-9.1.tar.bz2
        sudo rm -rf /usr/local/lib/vim91
        sudo mv vim91 /usr/local/lib/vim91
        rm -rf vim*
        cd -

        cd /usr/local/lib/vim91/src
        # @TODO Find a way to build this for various UNIX system
        make
        sudo make install
        cd -
        hash -r
    fi
}

# Install zellij
download_and_install_zellij() {
    if ! command -v zellij >/dev/null 2>&1; then
        echo =============Installing Zellij=====================
        cd /usr/local/bin
        sudo rm -f zellij.tar.gz
        sudo curl -L https://github.com/zellij-org/zellij/releases/download/v0.42.2/zellij-x86_64-unknown-linux-musl.tar.gz -o zellij.tar.gz
        sudo tar -xvf zellij.tar.gz
        sudo rm -f zellij.tar.gz
        sudo chmod 755 zellij
        cd -
        hash -r
    else
        echo "Zellij is already installed: $(zellij --version)"
    fi
}

# Install vim plugin and vim config
install_vim_plugin_and_config() {
    # Install vim-plug
    VIM_PLUG_PATH=~/.vim/autoload/plug.vim
    if [[ ! -f "$VIM_PLUG_PATH" ]]; then
        curl -fLo "$VIM_PLUG_PATH" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi

    # Copy vimrc
    local test_config_from_local=${1:-false}
    if [[ "$test_config_from_local" != "true" ]]; then
        curl -fLo ~/.vimrc \
            https://raw.githubusercontent.com/sieugee/vim-zellij-conf/master/vimrc/.vimrc
    else
        cp -f "$SCRIPT_DIR/vimrc/.vimrc" ~/.vimrc
    fi
    vim +PlugInstall +qall
    vim +PlugClean +qall

    # Install latest fzf, just in case user doesn't have permission to install
    cd ~/.vim/plugged/fzf
    sudo ./install
    cd -
    # Install ripgrep and fd-find for search
    # @TODO Find a better solution for other UNIX system
    SEARCH_APT_PKGS=("ripgrep" "fd-find")
    missing_pkg=false
    for pkg in "${REQUIRED_PKGS[@]}"; do
        if ! apt list --installed 2>/dev/null | grep -q "$pkg"; then
            missing_pkg=true
            break
        fi
    done
    if $missing_pkg; then
        sudo apt update
        sudo apt install -y "${REQUIRED_PKGS[@]}"
    fi
    if [[ -f /usr/local/bin/fd ]]; then
        echo "/usr/local/bin/fd already exists and is assumed to be mapped to fdfind."
    else
        sudo ln -s "$(which fdfind)" /usr/local/bin/fd
    fi

    # Add gitignore global for vim swap files (https://github.com/github/gitignore/blob/main/Global/Vim.gitignore)
    if ! grep -qxF '# vim swap files' ~/.gitignore_global 2>/dev/null; then
        cat >> ~/.gitignore_global <<'EOF'
# vim swap files
[._]*.s[a-v][a-z]
[._]*.sw[a-p]
[._]s[a-rt-v][a-z]
[._]ss[a-gi-z]
[._]sw[a-p]
EOF
    fi
    git config --global core.excludesfile ~/.gitignore_global
    # Set basrc move type to vi
    grep -qxF 'set -o vi' ~/.bashrc 2>/dev/null || echo "set -o vi" >> ~/.bashrc
    source ~/.bashrc
}

# Install zellij plugin and config
install_zellij_plugin_and_config() {
    # Copy zellij config
    local test_config_from_local=${1:-false}
    if [[ "$test_config_from_local" != "true" ]]; then
        curl -fLo  ~/.config/zellij/config.kdl \
            https://raw.githubusercontent.com/sieugee/vim-zellij-conf/master/zellij/config.kdl
    else
        cp -f "$SCRIPT_DIR/zellij/config.kdl"  ~/.config/zellij/config.kdl
    fi
}

# MAIN
parse_args "$@"
download_and_install_vim
install_vim_plugin_and_config "$test_context"
download_and_install_zellij
install_zellij_plugin_and_config "$test_context"

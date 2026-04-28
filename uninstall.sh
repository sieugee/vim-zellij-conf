#!/bin/bash
set -e

# Local install paths used by install.sh
VIM_LOCAL_DIR="/usr/local/lib/vim91"
VIM_LOCAL_BIN="/usr/local/bin/vim"
ZELLIJ_LOCAL_BIN="/usr/local/bin/zellij"

# Ask a yes/no question; returns 0 for yes, 1 for no. Default is no.
ask_yes_no() {
    local prompt="$1"
    local response
    while true; do
        read -r -p "$prompt [y/N]: " response
        case "$response" in
            [yY]|[yY][eE][sS]) return 0 ;;
            [nN]|[nN][oO]|"") return 1 ;;
            *) echo "Please answer yes or no." ;;
        esac
    done
}

# Remove vim 9 only if it was installed locally by install.sh, then restore system vim
uninstall_vim9() {
    echo "=============Vim 9 Uninstall====================="

    if [[ ! -d "$VIM_LOCAL_DIR" ]] && [[ ! -f "$VIM_LOCAL_BIN" ]]; then
        echo "Vim 9 was not installed by install.sh in $VIM_LOCAL_DIR. Skipping."
        return
    fi

    echo "Found local vim 9 installation:"
    [[ -d "$VIM_LOCAL_DIR" ]] && echo "  - source/build dir: $VIM_LOCAL_DIR"
    [[ -f "$VIM_LOCAL_BIN" ]] && echo "  - binary: $VIM_LOCAL_BIN"
    if command -v vim >/dev/null 2>&1; then
        echo "  - active vim: $(command -v vim) ($(vim --version 2>/dev/null | head -n1))"
    fi

    if ! ask_yes_no "Do you want to remove vim 9 and restore the original system vim?"; then
        echo "Skipping vim 9 uninstall."
        return
    fi

    # Run make uninstall first if the source tree is still around
    if [[ -f "$VIM_LOCAL_DIR/src/Makefile" ]]; then
        echo "Running 'make uninstall' from $VIM_LOCAL_DIR/src ..."
        (cd "$VIM_LOCAL_DIR/src" && sudo make uninstall) || \
            echo "make uninstall failed; will clean up manually."
    fi

    # Manual cleanup of common vim binaries that 'make install' creates
    sudo rm -f /usr/local/bin/vim \
               /usr/local/bin/vimdiff \
               /usr/local/bin/vimtutor \
               /usr/local/bin/view \
               /usr/local/bin/ex \
               /usr/local/bin/rvim \
               /usr/local/bin/rview \
               /usr/local/bin/evim \
               /usr/local/bin/eview
    sudo rm -rf /usr/local/share/vim
    sudo rm -rf "$VIM_LOCAL_DIR"
    hash -r

    echo "Local vim 9 has been removed."

    # Restore system vim. If apt vim is already there, /usr/bin/vim should now win.
    if command -v vim >/dev/null 2>&1; then
        echo "System vim is still available: $(command -v vim) ($(vim --version 2>/dev/null | head -n1))"
    else
        echo "No vim found on PATH after removal."
        if ask_yes_no "Install the system vim package via apt?"; then
            sudo apt update
            sudo apt install -y vim
            hash -r
            echo "System vim installed: $(command -v vim) ($(vim --version 2>/dev/null | head -n1))"
        fi
    fi
}

# Remove copilot-chat.vim plugin and its config block from ~/.vimrc
uninstall_copilot_chat() {
    echo "=============copilot-chat.vim Uninstall====================="

    if [[ ! -f ~/.vimrc ]]; then
        echo "~/.vimrc not found. Skipping."
        return
    fi
    if ! grep -q '^" copilot-chat-begin' ~/.vimrc; then
        echo "copilot-chat.vim block not found in ~/.vimrc. Skipping."
        return
    fi

    if ! ask_yes_no "Do you want to remove copilot-chat.vim from your vimrc?"; then
        echo "Skipping copilot-chat.vim removal."
        return
    fi

    sed -i '/^" copilot-chat-begin/,/^" copilot-chat-end/d' ~/.vimrc
    echo "Removed copilot-chat.vim block from ~/.vimrc."

    if command -v vim >/dev/null 2>&1 && [[ -f ~/.vim/autoload/plug.vim ]]; then
        echo "Running PlugClean to remove plugin files..."
        vim '+PlugClean!' +qall || \
            echo "PlugClean failed; you may need to manually remove ~/.vim/plugged/copilot-chat.vim"
    elif [[ -d ~/.vim/plugged/copilot-chat.vim ]]; then
        rm -rf ~/.vim/plugged/copilot-chat.vim
        echo "Removed ~/.vim/plugged/copilot-chat.vim"
    fi
}

# Remove zellij installed by install.sh
uninstall_zellij() {
    echo "=============Zellij Uninstall====================="

    if [[ ! -f "$ZELLIJ_LOCAL_BIN" ]] && ! command -v zellij >/dev/null 2>&1; then
        echo "Zellij is not installed. Skipping."
        return
    fi

    if [[ -f "$ZELLIJ_LOCAL_BIN" ]]; then
        echo "Found zellij at $ZELLIJ_LOCAL_BIN ($($ZELLIJ_LOCAL_BIN --version 2>/dev/null))"
    fi

    if ! ask_yes_no "Do you want to remove zellij?"; then
        echo "Skipping zellij uninstall."
        return
    fi

    sudo rm -f "$ZELLIJ_LOCAL_BIN"
    hash -r
    echo "Zellij has been removed."
}

# MAIN
echo "=== Uninstall script for vim-zellij-conf ==="
echo "This will ask you one by one which components to remove."
echo ""

uninstall_vim9
echo ""
uninstall_copilot_chat
echo ""
uninstall_zellij

echo ""
echo "=== Uninstall complete ==="

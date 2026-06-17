" --- Vim Settings ---
set nocompatible            " Be iMproved, required for many plugins
filetype plugin indent on   " Enable file type detection, plugins, and indenting
syntax enable               " Enable syntax highlighting

" Line Numbers
set number                  " Show absolute line number for the current line

" Indentation
set autoindent              " Auto indent on new lines
set tabstop=4               " Number of spaces a tab counts for
set shiftwidth=4            " Number of spaces for (auto)indent
set expandtab               " Use spaces instead of tabs (recommended for consistency)
set backspace=indent,eol,start " Make backspace work as expected

" UI & Behavior
set nowrap                  " Don't wrap lines (prefer horizontal scrolling)
set termguicolors           " Enable true color support for themes (requires a modern terminal)
set encoding=utf-8          " Set encoding to UTF-8
set hidden                  " Allow background buffers (don't force saving before switching)
set scrolloff=8             " Lines of context above/below the cursor
set cmdheight=2             " Command line height (useful for plugin messages)
set updatetime=300          " Faster update for plugins (e.g., diagnostics, CursorHold)

" Search
set hlsearch                " Highlight all search results
set incsearch               " Show search results as you type

" Undo History
set undofile                " Persist undo history after closing files
set undodir=~/.vim/undodir  " Directory for undo files (create this directory: mkdir -p ~/.vim/undodir)

" --- Other General Keybindings / Customizations ---
" Highlight current line (subtle background change)
set cursorline

" Navigate between buffer
nnoremap <leader><Tab> :bnext<CR>
nnoremap <leader><S-Tab> :bprev<CR>

" Language input toggle. Using <leader><Space> based on Windows' Win+Space key
" In my case, it's Vietnamese. Update to your language or add new
nnoremap <leader><Space> :call ToggleLanguageKeyMap()<CR>
inoremap <leader><Space> <C-O>:call ToggleLanguageKeyMap()<CR>

let g:keymaps = ['', 'vietnamese-telex_utf-8']
let g:keymap_index=0
function! ToggleLanguageKeyMap()
    let g:keymap_index = (g:keymap_index + 1) % len(g:keymaps)
    let new_keymap = g:keymaps[g:keymap_index]
    execute 'set keymap=' . new_keymap
endfunction

" Buffer lock functionality to replace winfixbuf for older Vim versions
let g:locked_windows = {}

function! LockCurrentWindow()
  let g:locked_windows[win_getid()] = bufnr('%')
endfunction

function! CheckWindowLock()
  let winid = win_getid()
  if has_key(g:locked_windows, winid)
    if bufnr('%') != g:locked_windows[winid]
      exe 'b' g:locked_windows[winid]
    endif
  endif
endfunction

"
" --- Plugin Manager (vim-plug) Setup ---
call plug#begin('~/.vim/plugged')

" fzf for fuzzy finding
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

" Fern for file exploration
Plug 'lambdalisue/fern.vim'
Plug 'lambdalisue/fern-git-status.vim'
Plug 'lambdalisue/nerdfont.vim'  " Optional for icons
Plug 'lambdalisue/vim-fern-renderer-nerdfont'  " Optional for icons
Plug 'brandon1024/fern-renderer-nf.vim' " Custom nerdfont renderer for fern

" Ayu color theme
Plug 'ayu-theme/ayu-vim'

" Automatically closes brackets, parentheses, and quotes.
Plug 'jiangmiao/auto-pairs'

" Easy commenting/uncommenting by Ctrl +/
Plug 'tpope/vim-commentary'

" Show tabs and status bar below
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
"
" For git
Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-signify'

" For non-Latin
Plug 'rlue/vim-barbaric'

" copilot-chat-begin (managed by install.sh / uninstall.sh)
Plug 'DanBradbury/copilot-chat.vim'
" copilot-chat-end

" Icon theme, should be the last one
Plug 'ryanoasis/vim-devicons'
call plug#end()

" Add global BufEnter autocmd for buffer lock checking
autocmd BufEnter * call CheckWindowLock()

" fzf settings
"set wildignore+=*/.git/*
let $FZF_DEFAULT_COMMAND = 'fd --type f --hidden --follow --exclude .git'

" airline seting
let g:airline_powerline_fonts = 1 "Adding icon to line
let g:airline#extensions#tabline#enabled = 1 " Enable the tabline
let g:airline#extensions#tabline#show_buffers =  1 " Show buffers when only one tab is openn
let g:airline#extensions#tabline#buffer_nr_show = 1 " Show buffer numbers
let g:airline#extensions#tabline#formatter = 'unique_tail' " Simplified buffer name format
let g:airline#extensions#branch#enabled = 1 " Enable displaying git branch

" Ayu settings
let ayucolor="mirage"
colorscheme ayu
let g:airline_theme ='ayu_mirage'

" Fern settings
let g:fern#disable_drawer_auto_quit = 0 "Quit if Fern is the last window
let g:fern#disable_viewer_git_status = 0 "Show git status in Fern
let g:fern#default_hidden = 1 "Show hidden file
let g:fern#renderer = "brandon1024/fern-renderer-nf.vim" "custom look for fern

" Shortkey
nnoremap <leader>p :Files<CR>
nnoremap <leader>f :Rg<CR>
nnoremap <leader>b :Fern . -drawer -toggle<CR>

" vnoremap <leader>y :w !clip.exe<CR>
vnoremap <leader>y y:call system('clip.exe', @")<CR>

" Auto-open Fern at start
" augroup FernAutoStart
"   autocmd!
"   autocmd VimEnter * ++nested Fern . -drawer -reveal=%
" augroup END

augroup fern_config
  autocmd!
  autocmd FileType fern setlocal nonumber norelativenumber "no line number on fern
  autocmd FileType fern call LockCurrentWindow()
  " Remove file using \D
  autocmd FileType fern nnoremap <buffer> <leader>D <Plug>(fern-action-remove)
augroup END

" copilot-chat-begin (managed by install.sh / uninstall.sh)
" Github copilot - CopilotChat View settings
augroup copilot_chat_config
    autocmd!
    autocmd FileType copilot_chat setlocal number
    autocmd FileType copilot_chat call LockCurrentWindow()
    autocmd FileType copilot_chat vertical resize 60 "don't let it take space of our main editor window
augroup END
" copilot-chat-end

"Search settings


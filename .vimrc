" ~/.vimrc — practical Vim for Linux administration, Ansible and RH labs
" No plugins on purpose: works on any stock vim-enhanced install and is easy
" to copy to a box you log in to. Safe defaults; YAML tuned for Ansible.
" Install as: ~/.vimrc

set nocompatible
scriptencoding utf-8

" File detection, syntax and file-specific indentation
filetype plugin indent on
syntax enable

" ---------------------------------------------------------------------------
" General editing
" ---------------------------------------------------------------------------
set encoding=utf-8
set number
set ruler
set showcmd
set showmatch
set hidden
set autoread
set confirm
set backspace=indent,eol,start
set history=1000
set scrolloff=5
set sidescrolloff=5
set splitbelow
set splitright
set updatetime=300
set timeoutlen=500
set ttimeoutlen=50
set nomodeline          " ignore modelines in opened files (safer on servers)
set mouse=              " keep terminal-native copy/paste; don't grab selection

" Reload files changed outside Vim (pairs with autoread)
augroup auto_reload
  autocmd!
  autocmd FocusGained,BufEnter * silent! checktime
augroup END

" ---------------------------------------------------------------------------
" Indentation — spaces by default; file types below override as needed
" ---------------------------------------------------------------------------
set autoindent
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4
set shiftround

" ---------------------------------------------------------------------------
" Search
" ---------------------------------------------------------------------------
set ignorecase
set smartcase
set incsearch
set hlsearch

" ---------------------------------------------------------------------------
" Completion
" ---------------------------------------------------------------------------
set wildmenu
set wildmode=longest:full,full
set wildignorecase
set completeopt=menuone,noselect

" ---------------------------------------------------------------------------
" Display
" ---------------------------------------------------------------------------
set nolist
set listchars=tab:>-,trail:.,extends:>,precedes:<,nbsp:+
set nowrap
set colorcolumn=81
set laststatus=2

" Compact, plugin-free status line.
" Shows: path  flags   [filetype] encoding fileformat  line:col  percent
" (fileformat is handy for spotting stray dos/CRLF line endings.)
set statusline=%<%f\ %h%m%r%=%y\ %{&fenc!=#''?&fenc:&enc}\ %{&ff}\ %l:%c\ %P

" Jump back to the last cursor position when reopening a file
augroup last_position
  autocmd!
  autocmd BufReadPost *
        \ if line("'\"") >= 1 && line("'\"") <= line("$") && &filetype !~# 'commit'
        \ |   execute "normal! g`\""
        \ | endif
augroup END

" ---------------------------------------------------------------------------
" Swap, backup and undo — kept out of your working directories
" ---------------------------------------------------------------------------
let s:vim_state = expand('~/.vim/state')
if exists('*mkdir')
  call mkdir(s:vim_state . '/swap',   'p', 0700)
  call mkdir(s:vim_state . '/backup', 'p', 0700)
  call mkdir(s:vim_state . '/undo',   'p', 0700)
endif
execute 'set directory^=' . fnameescape(s:vim_state . '/swap//')
execute 'set backupdir^=' . fnameescape(s:vim_state . '/backup//')
set backup
set writebackup
if has('persistent_undo')
  set undofile
  execute 'set undodir^=' . fnameescape(s:vim_state . '/undo//')
endif

" Never write swap/undo/backup for secrets, so plaintext can't leak to disk.
" Matches by filename (Ansible Vault files, keys, GPG) and by a vault header.
augroup sensitive_files
  autocmd!
  autocmd BufNewFile,BufRead *vault*,*secret*,*.gpg,*.asc,*.pem,*.key
        \ setlocal noswapfile noundofile nobackup nowritebackup
  autocmd BufReadPost *
        \ if getline(1) =~# '^\$ANSIBLE_VAULT'
        \ |   setlocal noswapfile noundofile nobackup nowritebackup
        \ | endif
augroup END

" ---------------------------------------------------------------------------
" Clipboard and colour — only when the build/terminal supports it
" ---------------------------------------------------------------------------
if has('clipboard')
  set clipboard=unnamedplus
endif
if exists('+termguicolors') && $COLORTERM =~# 'truecolor\|24bit'
  set termguicolors
endif

" ------------------------------------------------------------

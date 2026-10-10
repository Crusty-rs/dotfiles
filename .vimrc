" ~/.vimrc — practical Vim for Linux administration, Ansible and RH labs


set nocompatible
set encoding=utf-8            " must come before scriptencoding
scriptencoding utf-8

" File detection, syntax and file-specific indentation
filetype plugin indent on
syntax enable

let mapleader = ' '

" ---------------------------------------------------------------------------
" General editing
" ---------------------------------------------------------------------------
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
set nrformats-=octal    " Ctrl-A on 007 gives 008, not 010 (think file modes)
set nojoinspaces        " J joins with one space, not two
set formatoptions+=j    " J removes comment leaders when joining comment lines
set display=lastline    " show as much of a long last line as fits, not @@@
set belloff=all         " no beeps or flashes

" Show "[3/12]" match count when searching (Vim 8.1.1270+)
if has('patch-8.1.1270')
  set shortmess-=S
endif

" Reload files changed outside Vim (pairs with autoread)
augroup auto_reload
  autocmd!
  autocmd FocusGained,BufEnter,CursorHold * silent! checktime
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
set wildignore+=*.retry,*.pyc,*/__pycache__/*,*.swp,*.o,*.rpm,*.tar.gz,*.iso
set completeopt=menuone,noselect
set path+=**            " :find across the project (handy in Ansible roles)

" ---------------------------------------------------------------------------
" Display
" ---------------------------------------------------------------------------
set nolist
set listchars=tab:>-,trail:.,extends:>,precedes:<,nbsp:+
set nowrap
set colorcolumn=81
set laststatus=2
set background=dark     " most SSH terminals are dark; change to light if not

" Compact, plugin-free status line.
" Shows: path  flags [PASTE]   [filetype] encoding fileformat  line:col  percent
" (fileformat is handy for spotting stray dos/CRLF line endings.)
set statusline=%<%f\ %h%m%r%{&paste?'\ [PASTE]':''}%=%y\ %{&fenc!=#''?&fenc:&enc}\ %{&ff}\ %l:%c\ %P

" Highlight trailing whitespace in red (not while typing on that line)
highlight default ExtraWhitespace ctermbg=red guibg=red
augroup trailing_ws
  autocmd!
  autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
  autocmd BufWinEnter,InsertLeave * if &buftype ==# '' | match ExtraWhitespace /\s\+$/ | endif
  autocmd InsertEnter * if &buftype ==# '' | match ExtraWhitespace /\s\+\%#\@<!$/ | endif
augroup END

" Jump back to the last cursor position when reopening a file
augroup last_position
  autocmd!
  autocmd BufReadPost *
        \ if line("'\"") >= 1 && line("'\"") <= line("$") && &filetype !~# 'commit'
        \ |   execute "normal! g`\""
        \ | endif
augroup END

" ---------------------------------------------------------------------------
" File types — Ansible / YAML, Jinja2 templates and common admin files
" ---------------------------------------------------------------------------
augroup filetype_detect_extra
  autocmd!
  " Ansible inventories without an extension are INI-style
  autocmd BufNewFile,BufRead */inventory/hosts,*/inventory setfiletype dosini
  autocmd BufNewFile,BufRead ansible.cfg,.ansible-lint setfiletype dosini
  autocmd BufNewFile,BufRead *.yml.j2,*.yaml.j2 set filetype=yaml
  " Other Jinja2 templates: detect by the name without .j2 (nginx.conf.j2 -> nginx)
  autocmd BufNewFile,BufRead *.j2
        \ if &filetype ==# '' |
        \   execute 'doautocmd filetypedetect BufRead ' . fnameescape(expand('<afile>:r')) |
        \ endif
  autocmd BufNewFile,BufRead *.repo setfiletype dosini
  autocmd BufNewFile,BufRead Containerfile* setfiletype dockerfile
augroup END

augroup filetype_settings
  autocmd!
  " YAML / Ansible: 2-space indent, no tab characters, no auto-reindent while
  " typing ':' or '#', and show invisibles so a stray tab is easy to spot.
  autocmd FileType yaml,yaml.ansible
        \ setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
        \          indentkeys-=0# indentkeys-=<:> list cursorcolumn
  autocmd FileType yaml,yaml.ansible
        \ if executable('yamllint') |
        \   setlocal makeprg=yamllint\ -f\ parsable\ % errorformat=%f:%l:%c:\ %m |
        \ endif
  " Shell: lint with shellcheck when it exists (F5 / :make)
  autocmd FileType sh,bash
        \ if executable('shellcheck') |
        \   setlocal makeprg=shellcheck\ -f\ gcc\ % |
        \ endif
  autocmd FileType json,html,xml,jinja,ruby,lua
        \ setlocal tabstop=2 softtabstop=2 shiftwidth=2
  autocmd FileType make setlocal noexpandtab tabstop=8 shiftwidth=8 softtabstop=0
  autocmd FileType python setlocal colorcolumn=80,100
  autocmd FileType gitcommit,markdown,text setlocal spell wrap linebreak
  autocmd FileType gitcommit setlocal colorcolumn=51,73
  " crontab -e needs Vim to overwrite the file in place
  autocmd FileType crontab setlocal nobackup nowritebackup backupcopy=yes
augroup END

" ---------------------------------------------------------------------------
" Key mappings
" ---------------------------------------------------------------------------
nnoremap <silent> <Leader><Space> :nohlsearch<CR>
nnoremap <silent> <Leader>w :update<CR>
nnoremap <silent> <Leader>l :setlocal list!<CR>
nnoremap <silent> <Leader>n :setlocal number!<CR>
nnoremap <silent> <Leader>p :set paste!<CR>
nnoremap <silent> <Leader>s :setlocal spell!<CR>
nnoremap <silent> <Leader>e :Explore<CR>
nnoremap <silent> <F5> :make<CR>:cwindow<CR>

" Strip trailing whitespace without moving the cursor or losing your search
nnoremap <silent> <Leader>W :let _s=@/ <Bar> let _v=winsaveview() <Bar>
      \ keeppatterns %s/\s\+$//e <Bar> call winrestview(_v) <Bar> let @/=_s<CR>

" Keep the selection after shifting indent in visual mode
xnoremap < <gv
xnoremap > >gv

" Y yanks to end of line, like C and D
nnoremap Y y$

" Move by screen line when lines wrap, unless a count is given (5j still works)
nnoremap <expr> j v:count ? 'j' : 'gj'
nnoremap <expr> k v:count ? 'k' : 'gk'

" :w!! — save a file you opened without sudo
cnoremap w!! w !sudo tee % >/dev/null

" netrw: tree view, no banner
let g:netrw_banner = 0
let g:netrw_liststyle = 3

" ---------------------------------------------------------------------------
" Swap, backup and undo — kept out of your working directories
" ---------------------------------------------------------------------------
let s:vim_state = expand('~/.vim/state')
if exists('*mkdir')
  for s:dir in ['swap', 'backup', 'undo']
    if !isdirectory(s:vim_state . '/' . s:dir)
      call mkdir(s:vim_state . '/' . s:dir, 'p', 0700)
    endif
  endfor
endif
execute 'set directory^=' . fnameescape(s:vim_state . '/swap//')
" A trailing // in backupdir (full-path names, no collisions) needs 8.1.0251
if has('patch-8.1.0251')
  execute 'set backupdir^=' . fnameescape(s:vim_state . '/backup//')
else
  execute 'set backupdir^=' . fnameescape(s:vim_state . '/backup')
endif
set backup
set writebackup
set backupskip+=/dev/shm/*,*/.git/*
if has('persistent_undo')
  set undofile
  execute 'set undodir^=' . fnameescape(s:vim_state . '/undo//')
endif

" Remember marks for 200 files, but at most 50 lines / 10 KB per register, so
" a pasted secret isn't stored in full in ~/.viminfo
if !has('nvim')
  set viminfo='200,<50,s10,h
endif

" Never write swap/undo/backup for secrets, so plaintext can't leak to disk.
" Matches by filename (Ansible Vault files, keys, GPG) and by a vault header.
augroup sensitive_files
  autocmd!
  autocmd BufNewFile,BufRead *vault*,*secret*,*.gpg,*.asc,*.pem,*.key,id_rsa*,id_ed25519*,*.kdbx
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

" Machine-specific overrides that shouldn't live in the shared file
if filereadable(expand('~/.vimrc.local'))
  execute 'source ' . fnameescape(expand('~/.vimrc.local'))
endif

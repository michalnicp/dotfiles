" Plugins --------------------------------------------------------------------
call plug#begin('~/.local/share/nvim/plugged')

Plug 'joshdick/onedark.vim'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-go', { 'do': 'make'}
Plug 'sebastianmarkow/deoplete-rust'
Plug 'scrooloose/nerdtree' " file explorer
Plug 'vim-airline/vim-airline' " status bar
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-fugitive' " git
Plug 'airblade/vim-gitgutter' " git signs in gutter
Plug 'scrooloose/nerdcommenter' " comment functions
Plug 'w0rp/ale' " linter
Plug 'junegunn/fzf.vim'
Plug 'fatih/vim-go'
Plug 'rust-lang/rust.vim' " rust
Plug 'racer-rust/vim-racer'
" Plug 'Yggdroot/indentLine'

call plug#end()

" General --------------------------------------------------------------------
set nowrap                  " do not wrap lines
set number                  " show line numbers
set ruler                   " always show current position
set showcmd                 " show command in bottom bar

" spaces & tabs
set expandtab               " tabs are spaces
set smarttab                " be smart when using tabs
set tabstop=4               " number of visual spaces fer TAB
set softtabstop=4           " number of spaces in tab when editing
set shiftwidth=4

syntax enable

" Colorscheme
set background=dark
colorscheme onedark

filetype plugin indent on

" invisible characters
set list
set listchars=tab:>·,trail:~,extends:>,precedes:<
" set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<,space:␣

" auto-comment
set formatoptions+=cro

" enable mouse
set mouse=a

" autogroups
augroup filetypes
    autocmd!
    autocmd BufRead,BufNewFile *.vue setlocal filetype=vue.html.javascript.css
    autocmd FileType javascript,json,gohtmltmpl,html,yaml,ruby,eruby setlocal ts=2 sts=2 sw=2
    autocmd FileType json setlocal conceallevel=0 " don't hide quotes
augroup END

" Mappings

" change the mapleader from \ to ,
let mapleader = ","

" remap esc
inoremap jk <esc>

" toggle paste
set pastetoggle=<leader>v

" movement
nnoremap j gj
nnoremap k gk

" movement between splits
nnoremap <c-j> <c-w><c-j>
nnoremap <c-k> <c-w><c-k>
nnoremap <c-l> <c-w><c-l>
nnoremap <c-h> <c-w><c-h>

" Functions ------------------------------------------------------------------

" trim trailing whitespace
function TrimTrailingWhitespace()
    if &l:modifiable
        " don't lose user position when trimming trailing whitespace
        let s:view = winsaveview()
        try
            silent! %s/\s\+$//e
        finally
            call winrestview(s:view)
        endtry
    endif
endfunction

" linespec filename:line
function LineSpec()
    let linespec = @% . ":" . line(".")
    echo linespec
    call system("xsel -b", linespec)
endfunction
nnoremap <leader>ls :call LineSpec()<CR>

" Plugin configuration -------------------------------------------------------

" Deoplete
let g:deoplete#enable_at_startup = 1
let g:deoplete#disable_auto_complete = 1
inoremap <silent><expr> <TAB>
\ pumvisible() ? "\<C-n>" :
\ <SID>check_back_space() ? "\<TAB>" :
\ deoplete#mappings#manual_complete()
function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
endfunction

" NERDTree
map <C-n> :NERDTreeToggle<CR>
nnoremap <leader>nf :NERDTreeFind<CR>

" NERDCommenter
let g:NERDDefaultAlign = "left"
let g:NERDSpaceDelims = 1

" Airline
let g:airline_powerline_fonts = 1
let g:airline_inactive_collapse=1

" vim-go
let g:go_fmt_command = "goimports"
let g:go_template_autocreate = 0

" fzf.vim
nnoremap <silent> <leader><space> :Files<CR>
nnoremap <silent> <leader>a :Buffers<CR>

" ale
let g:ale_sign_column_always = 1

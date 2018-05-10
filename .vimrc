"""""""""""""""""""""
" Vim Configuration "
"""""""""""""""""""""

" Use the following lines to link nvim to .vimrc
" ln -s ~/.vim ~/.config/nvim
" ln -s ~/.vimrc ~/.config/nvim/init.vim


""""""""""""""""""
" Plugin Section "
""""""""""""""""""

" Install Vim-Plug manager with this:
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

call plug#begin()

" Custom Colorschemes
Plug 'morhetz/gruvbox'
Plug 'nightsense/seabird'
Plug 'altercation/vim-colors-solarized'
Plug 'zanglg/nova.vim'
Plug 'marcopaganini/termschool-vim-theme'
Plug 'joshglendenning/vim-darcula-colors'

" Adaptive colorscheme
Plug 'dylanaraps/wal'

" Nerd tree directory view (loads on demand)
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle'}

" Powerline or airline
if !has("nvim")
    set rtp+=/usr/lib/python2.7/site-packages/powerline/bindings/vim/
else
" Airline advanced information bar
    Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'
endif

call plug#end()


"""""""""""""""""""
" General Options "
"""""""""""""""""""

set nocompatible

" Set line numbers
set number

" Uses spaces instead of tabs
set expandtab
" 1 tab equals 4 spaces
set shiftwidth=4
set tabstop=4
" set autoindent
"set ai

" set smart indent
filetype plugin indent on

" set wrap lines
set wrap

" prevent background issues when running in tmux
if &term =~ '256color'
    set t_ut=
endif


""""""""""""""""""
" Plugin Options "
""""""""""""""""""

" Always show airline!
set laststatus=2

" Automatically populate dict with proper symbols
""let g:airline_powerline_fonts=1
""if !exists('g:airline_symbols')
""    let g:airline_symbols = {}
""endif

" remove accidental lag
set ttimeoutlen=5

" Powerline config
let g:Powerline_symbols = 'fancy'

" unicode symbols
let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
"let g:airline_symbols.linenr = '␊'
"let g:airline_symbols.linenr = '␤'
"let g:airline_symbols.linenr = '¶'
"let g:airline_symbols.branch = '⎇'
"let g:airline_symbols.paste = 'ρ'
"let g:airline_symbols.paste = 'Þ'
"let g:airline_symbols.paste = '∥'
"let g:airline_symbols.whitespace = 'Ξ'


""""""""""""""""""""""""""""""""""""""""""""""
" Key Mappings for easier delimiter handling "
""""""""""""""""""""""""""""""""""""""""""""""

inoremap ( ()<Esc>i
inoremap [ []<Esc>i
inoremap { {<CR>}<Esc>O
autocmd Syntax html,vim inoremap < <lt>><Esc>i| inoremap > <c-r>=ClosePair('>')<CR>
inoremap ) <c-r>=ClosePair(')')<CR>
inoremap ] <c-r>=ClosePair(']')<CR>
inoremap } <c-r>=CloseBracket()<CR>
inoremap " <c-r>=QuoteDelim('"')<CR>
inoremap ' <c-r>=QuoteDelim("'")<CR>

function ClosePair(char)
    if getline('.')[col('.') - 1] == a:char
        return "\<Right>"
    else
        return a:char
    endif
endf

function CloseBracket()
    if match(getline(line('.') + 1), '\s*}') < 0
        return "\<CR>}"
    else
        return "\<Esc>j0f}a"
    endif
endf

function QuoteDelim(char)
    let line = getline('.')
    let col = col('.')
    if line[col - 2] == "\\"
        "Inserting a quoted quotation mark into the string
        return a:char
    elseif line[col - 1] == a:char
        "Escaping out of the string
        return "\<Right>"
    else
        "Starting a string
        return a:char.a:char."\<Esc>i"
    endif
endf


"""""""""""""""""""""""
" Enable file jumping "
"""""""""""""""""""""""

" Search down into subfolders
" Provides tab-completion for all file-related tasks
set path+=**

" Display all matching files when we tab-complete
set wildmenu


""""""""""""""""""""
" Coloring Options "
""""""""""""""""""""

" Set true color
set t_Co=256

" Some special treatment for neovim
if has("vim")
    " Enable True Color Support, if available
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    set termguicolors

    " Let the background be normal terminal style to keep consistency
    au ColorScheme * highlight Normal ctermbg=none guibg=none
    au ColorScheme * highlight NonText ctermbg=none guibg=none
endif

"
" This has to come first
set background=dark

" Enable syntax highlighting
syntax enable

" Set color scheme
colorscheme nova

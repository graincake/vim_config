" Environment {

    " Identify platform {
        silent function! OSX()
            return has('macunix')
        endfunction
        silent function! LINUX()
            return has('unix') && !has('macunix') && !has('win32unix')
        endfunction
        silent function! WINDOWS()
            return  (has('win32') || has('win64'))
        endfunction
    " }

    " Basics {
        set nocompatible        " Must be first line
        if !WINDOWS()
            set shell=/bin/bash
        endif
    " }

    " Windows Compatible {
        " On Windows, also use '.vim' instead of 'vimfiles'; this makes synchronization
        " across (heterogeneous) systems easier.
        if WINDOWS()
          set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
          " Be nice and check for multi_byte even if the config requires
          " multi_byte support most of the time
          if has("multi_byte")
            " Windows cmd.exe still uses cp850. If Windows ever moved to
            " Powershell as the primary terminal, this would be utf-8
            set termencoding=cp850
            " Let Vim use utf-8 internally, because many scripts require this
            set encoding=utf-8
            setglobal fileencoding=utf-8
            " Windows has traditionally used cp1252, so it's probably wise to
            " fallback into cp1252 instead of eg. iso-8859-15.
            " Newer Windows files might contain utf-8 or utf-16 LE so we might
            " want to try them first.
            set fileencodings=ucs-bom,utf-8,utf-16le,cp1252,iso-8859-15
          endif
        endif
    " }

    " Arrow Key Fix {
        " https://github.com/spf13/spf13-vim/issues/780
        if &term[:4] == "xterm" || &term[:5] == 'screen' || &term[:3] == 'rxvt'
            inoremap <silent> <C-[>OC <RIGHT>
        endif
    " }

    " Strip whitespace {
    function! StripTrailingWhitespace()
        " Preparation: save last search, and cursor position.
        let _s=@/
        let l = line(".")
        let c = col(".")
        " do the business:
        %s/\s\+$//e
        " clean up: restore previous search history, and cursor position
        let @/=_s
        call cursor(l, c)
    endfunction
    " }

    " Use before config if available {
    "    if filereadable(expand("~/.vimrc.before"))
    "        source ~/.vimrc.before
    "    endif
    " }
" }

" General {

    set background=dark         " Assume a dark background

    " Allow to trigger background
    function! ToggleBG()
        let s:tbg = &background
        " Inversion
        if s:tbg == "dark"
            set background=light
        else
            set background=dark
        endif
    endfunction
    noremap <leader>bg :call ToggleBG()<CR>

    " if !has('gui')
        "set term=$TERM          " Make arrow and other keys work
    " endif
    filetype plugin indent on   " Automatically detect file types.
    syntax on                   " Syntax highlighting
    set mouse=a                 " Automatically enable mouse usage
    set mousehide               " Hide the mouse cursor while typing
    scriptencoding utf-8

    if has('clipboard')
        if has('unnamedplus')  " When possible use + register for copy-paste
            set clipboard=unnamed,unnamedplus
        else         " On mac and Windows, use * register for copy-paste
            set clipboard=unnamed
        endif
    endif

    "set autowrite                       " Automatically write a file when leaving a modified buffer
    set shortmess+=filmnrxoOtT          " Abbrev. of messages (avoids 'hit enter')
    set viewoptions=folds,options,cursor,unix,slash " Better Unix / Windows compatibility
    "set virtualedit=onemore             " Allow for cursor beyond last character
    set history=1000                    " Store a ton of history (default is 20)
    "set spell                           " Spell checking on
    set hidden                          " Allow buffer switching without saving

    " Instead of reverting the cursor to the last position in the buffer, we
    " set it to the first line when editing a git commit message
    au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

    " http://vim.wikia.com/wiki/Restore_cursor_to_file_position_in_previous_editing_session
    " Restore cursor to file position in previous editing session
    " To disable this, add the following to your .vimrc.before.local file:
    "   let g:spf13_no_restore_cursor = 1
    if !exists('g:spf13_no_restore_cursor')
        function! ResCur()
            if line("'\"") <= line("$")
                silent! normal! g`"
                return 1
            endif
        endfunction

        augroup resCur
            autocmd!
            autocmd BufWinEnter * call ResCur()
        augroup END
    endif

    " 自动切换目录为当前编辑文件所在目录
    au BufRead,BufNewFile,BufEnter * cd %:p:h

" }

" Formatting {

    set nowrap                      " Do not wrap long lines
    set autoindent                  " Indent at the same level of the previous line
    set shiftwidth=4                " Use indents of 4 spaces
    set expandtab                   " Tabs are spaces, not tabs
    set tabstop=4                   " An indentation every four columns
    set softtabstop=4               " Let backspace delete indent
    set nojoinspaces                " Prevents inserting two spaces after punctuation on a join (J)
    set splitright                  " Puts new vsplit windows to the right of the current
    set splitbelow                  " Puts new split windows to the bottom of the current
    "set matchpairs+=<:>             " Match, to be used with %
    set pastetoggle=<F12>           " pastetoggle (sane indentation on pastes)
    "set comments=sl:/*,mb:*,elx:*/  " auto format comment blocks
    " Remove trailing whitespaces and ^M chars
    " To disable the stripping of whitespace, add the following to your
    " .vimrc.before.local file:
    "   let g:spf13_keep_trailing_whitespace = 1
    autocmd FileType c,cpp,java,go,php,javascript,puppet,python,rust,twig,xml,yml,perl,sql autocmd BufWritePre <buffer> if !exists('g:spf13_keep_trailing_whitespace') | call StripTrailingWhitespace() | endif
    "autocmd FileType go autocmd BufWritePre <buffer> Fmt
    autocmd BufNewFile,BufRead *.html.twig set filetype=html.twig
    autocmd FileType haskell,puppet,ruby,yml setlocal expandtab shiftwidth=2 softtabstop=2
    " preceding line best in a plugin but here for now.

    autocmd BufNewFile,BufRead *.coffee set filetype=coffee

    " Workaround vim-commentary for Haskell
    autocmd FileType haskell setlocal commentstring=--\ %s
    " Workaround broken colour highlighting in Haskell
    autocmd FileType haskell,rust setlocal nospell

" }

" Key (re)Mappings {

    " The default leader is '\', but many people prefer ',' as it's in a standard
    " location.
    " let mapleader = ','
    "

    " Easier moving in tabs and windows
    " The lines conflict with the default digraph mapping of <C-K>
    " If you prefer that functionality, add the following to your
    " .vimrc.before.local file:
    "   let g:spf13_no_easyWindows = 1
    if !exists('g:spf13_no_easyWindows')
        map <C-J> <C-W>j<C-W>_
        map <C-K> <C-W>k<C-W>_
        map <C-L> <C-W>l<C-W>_
        map <C-H> <C-W>h<C-W>_
    endif

    " Wrapped lines goes down/up to next row, rather than next line in file.
    noremap j gj
    noremap k gk

    " Shortcuts
    " Change Working Directory to that of the current file
    cmap cwd lcd %:p:h
    cmap cd. lcd %:p:h

    " Visual shifting (does not exit Visual mode)
    vnoremap < <gv
    vnoremap > >gv

    " Allow using the repeat operator with a visual selection (!)
    " http://stackoverflow.com/a/8064607/127816
    vnoremap . :normal .<CR>

    " For when you forget to sudo.. Really Write the file.
    cmap w!! w !sudo tee % >/dev/null

    " Adjust viewports to the same size
    map <Leader>= <C-w>=

    " Map <Leader>ff to display all lines with keyword under cursor
    " and ask which one to jump to
    nmap <Leader>ff [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>

    " Easier horizontal scrolling
    map zl zL
    map zh zH

    " Easier formatting
    nnoremap <silent> <leader>q gwip

    " FIXME: Revert this f70be548
    " fullscreen mode for GVIM and Terminal, need 'wmctrl' in you PATH
    map <silent> <F11> :call system("wmctrl -ir " . v:windowid . " -b toggle,fullscreen")<CR>

    " 窗口大小调整
    nnoremap + :resize +1<cr>
    nnoremap _ :resize -1<cr>
    nnoremap > :vertical resize +1<cr>
    nnoremap < :vertical resize -1<cr>
" }

" Vim UI {

    "if filereadable(expand("~/.vim/plugged/vim-colors-solarized/colors/solarized.vim"))
    "    let g:solarized_termcolors=256
    "    let g:solarized_termtrans=1
    "    let g:solarized_contrast="normal"
    "    let g:solarized_visibility="normal"
    "    "colorscheme solarized             " Load a colorscheme
    "endif
    colorscheme Tomorrow-Night-Eighties               "终端配色方案

    "highlight Functions，这可以高亮函数
    syn match cFunction /\<\w\+\%(\s*(\)\@=/
    hi default link cFunction Include

    set tabpagemax=15               " Only show 15 tabs
    set showmode                    " Display the current mode

    set cursorline                  " Highlight current line

    highlight clear SignColumn      " SignColumn should match background
    highlight clear LineNr          " Current line number row will have same background color in relative mode
    "highlight clear CursorLineNr    " Remove highlight color from current line number

    if has('cmdline_info')
        set ruler                   " Show the ruler
        set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " A ruler on steroids
        set showcmd                 " Show partial commands in status line and
                                    " Selected characters/lines in visual mode
    endif

    if has('statusline')
        set laststatus=2

        " Broken down into easily includeable segments
        set statusline=%<%f\                     " Filename
        set statusline+=%w%h%m%r                 " Options
        set statusline+=\ [%{&ff}/%Y]            " Filetype
        set statusline+=\ [%{getcwd()}]          " Current dir
        set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
    endif

    set backspace=indent,eol,start  " Backspace for dummies
    set linespace=0                 " No extra spaces between rows
    set number                      " Line numbers on
    set showmatch                   " Show matching brackets/parenthesis
    set incsearch                   " Find as you type search
    set hlsearch                    " Highlight search terms
    set winminheight=0              " Windows can be 0 line high
    set ignorecase                  " Case insensitive search
    set smartcase                   " Case sensitive when uc present
    set wildmenu                    " Show list instead of just completing
    set wildmode=list:longest,full  " Command <Tab> completion, list matches, then longest common part, then all.
    set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap too
    set scrolljump=5                " Lines to scroll when cursor leaves screen
    set scrolloff=3                 " Minimum lines to keep above and below cursor
    set foldenable                  " Auto fold code
    set foldmethod=manual
    set foldcolumn=1
    set list
    set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace
    " 常规模式下用空格键来开关光标行所在折叠（注：zR 展开所有折叠，zM 关闭所有折叠）
    nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>
    " 自动保存折叠
    "au BufWinLeave * silent mkview
    "au BufWinEnter * silent loadview

" }

" GUI Settings {

    " GVIM- (here instead of .gvimrc)
    if has('gui_running')
        set guioptions-=T           " Remove the toolbar
        set lines=40                " 40 lines of text instead of 24
        if !exists("g:spf13_no_big_font")
            if LINUX() && has("gui_running")
                set guifont=Andale\ Mono\ Regular\ 12,Menlo\ Regular\ 11,Consolas\ Regular\ 12,Courier\ New\ Regular\ 14
            elseif OSX() && has("gui_running")
                set guifont=Andale\ Mono\ Regular:h12,Menlo\ Regular:h11,Consolas\ Regular:h12,Courier\ New\ Regular:h14
            elseif WINDOWS() && has("gui_running")
                set guifont=Andale_Mono:h10,Menlo:h10,Consolas:h10,Courier_New:h10
            endif
        endif
    else
        if &term == 'xterm' || &term == 'screen'
            set t_Co=256            " Enable 256 colors to stop the CSApprox warning and make xterm vim shine
        endif
        "set term=builtin_ansi       " Make arrow and other keys work
    endif
    "if !WINDOWS()
    "    " Uncomment the following to have Vim jump to the last position when
    "    " reopening a file
    "    if has("autocmd")
    "        au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
    "    endif
    "    if has('gui_running')
    "        " Source a global configuration file if available
    "        if filereadable("/etc/vim/gvimrc.local")
    "            source /etc/vim/gvimrc.local
    "        endif
    "        set mousemodel=popup           " 在gvim下右键弹出菜单
    "    else
    "        " This line should not be removed as it ensures that various options are
    "        " properly set to work with the Vim-related packages available in Debian.
    "        runtime! debian.vim

    "        " Vim5 and later versions support syntax highlighting. Uncommenting the next
    "        " line enables syntax highlighting by default.
    "        if has("syntax")
    "            syntax on
    "        endif

    "        set mouse=a                    " 在任何模式下启用鼠标
    "        set t_Co=256                   " 在终端启用256色
    "        set backspace=2                " 设置退格键可用

    "        " Source a global configuration file if available
    "        if filereadable("/etc/vim/vimrc.local")
    "            source /etc/vim/vimrc.local
    "        endif
    "    endif

    "endif

" }

" Use Plugin Manager Plugs {
    call plug#begin('~/.vim/plugged')
        " gtags and gnu global support
        Plug 'vim-scripts/gtags.vim'
        Plug 'vim-scripts/autopreview'
        Plug 'vim-scripts/genutils'
        Plug 'ludovicchabant/vim-gutentags'
        Plug 'skywind3000/gutentags_plus'
        Plug 'skywind3000/vim-preview'
        " color
        Plug 'altercation/vim-colors-solarized'
        Plug 'lifepillar/vim-solarized8'      " solarized8
        "Plug 'ChrisKempson/Tomorrow-Theme'
        " language specific enhance
        Plug 'vim-scripts/c.vim'
        Plug 'vim-scripts/a.vim'
        Plug 'octol/vim-cpp-enhanced-highlight'
        Plug 'vim-scripts/cSyntaxAfter'
        " enhanced std\c++14 highlight
        Plug 'Mizuchi/STL-Syntax'
        Plug 'bronson/vim-trailing-whitespace'
            " file lookup
        Plug 'Yggdroot/LeaderF'
        Plug 'vim-scripts/matchit.zip'
        Plug 'vim-airline/vim-airline'
        Plug 'vim-airline/vim-airline-themes'

        Plug 'Shougo/neocomplcache.vim'

        Plug 'vim-scripts/OmniCppComplete'
        Plug 'msanders/snipmate.vim'
        Plug 'vim-scripts/std_c.zip'
        " restore_view confict with gutentags to not find ctags
        "Plug 'vim-scripts/restore_view.vim'

    call plug#end()
" }

" Plug Config {
" vim-gutentags {
    set cscopetag                  " 使用 cscope 作为 tags 命令
    set cscopeprg='gtags-cscope'
    set tags=./.tags;.tags
    let $GTAGSLABEL = 'native-pygments'
    "let $GTAGSLABEL = 'native'
    let $GTAGSCONF = '/usr/local/share/gtags/gtags.conf'
    let g:gutentags_project_root = ['.git','.root','.svn','.hg','.project']
    let g:gutentags_ctags_tagfile = '.tags'
    let g:gutentags_modules = []
    if executable('gtags-cscope') && executable('gtags')
        let g:gutentags_modules += ['gtags_cscope']
    endif
    if executable('ctags')
        let g:gutentags_modules += ['ctags']
    endif
    let g:gutentags_cache_dir = expand('~/.cache/tags')
    let g:gutentags_ctags_extra_args = []
    let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extras=+q']
    let g:gutentags_ctags_extra_args += ['--c++-kinds=+px']
    let g:gutentags_ctags_extra_args += ['--c-kinds=+px']

    let g:gutentags_ctags_extra_args += ['--output-format=e-ctags']
    let g:gutentags_auto_add_gtags_cscope = 0
    let g:gutentags_plus_switch = 1
    let g:asyncrun_bell = 1
    let g:gutentags_define_advanced_commands = 1
    let g:gutentags_generate_on_empty_buffer = 1    " open database

    "let g:gutentags_trace = 1
" }

" vim-preview {
    "P 预览 大p关闭
    autocmd FileType qf nnoremap <silent><buffer> p :PreviewQuickfix<cr>
    autocmd FileType qf nnoremap <silent><buffer> P :PreviewClose<cr>
    noremap <Leader>u :PreviewScroll -1<cr>     " 往上滚动预览窗口
    noremap <leader>d :PreviewScroll +1<cr>     " 往下滚动预览窗口
" }
" gutentags_plus {
    "noremap <silent> <leader>cs :GscopeFind s <C-R><C-W><cr>
    "noremap <silent> <leader>cg :GscopeFind g <C-R><C-W><cr>
    "noremap <silent> <leader>cc :GscopeFind c <C-R><C-W><cr>
    "noremap <silent> <leader>ct :GscopeFind t <C-R><C-W><cr>
    "noremap <silent> <leader>ce :GscopeFind e <C-R><C-W><cr>
    "noremap <silent> <leader>cf :GscopeFind f <C-R>=expand("<cfile>")<cr><cr>
    "noremap <silent> <leader>ci :GscopeFind i <C-R>=expand("<cfile>")<cr><cr>
    "noremap <silent> <leader>cd :GscopeFind d <C-R><C-W><cr>
    "noremap <silent> <leader>ca :GscopeFind a <C-R><C-W><cr>
    "noremap <silent> <leader>ck :GscopeKill<cr>
" }

    " LeaderF {
        let g:Lf_ShortcutF = '<c-p>'
        noremap <Leader>ff :LeaderfFunction<cr>
        noremap <Leader>fb :LeaderfBuffer<cr>
        noremap <Leader>ft :LeaderfTag<cr>
        noremap <Leader>fm :LeaderfMru<cr>
        noremap <Leader>fl :LeaderfLine<cr>

        let g:Lf_StlSeparator = { 'left': '', 'right': '', 'font': '' }
        let g:Lf_RootMarkers = ['.project', '.root', '.svn', '.git']
        let g:Lf_WorkingDirectoryMode = 'Ac'
        let g:Lf_WindowHeight = 0.30
        let g:Lf_CacheDirectory = expand('~/.vim/cache')
        let g:Lf_ShowRelativePath = 0
        let g:Lf_HideHelp = 1
        let g:Lf_StlColorscheme = 'powerline'
        let g:Lf_PreviewResult = {'Function':0, 'BufTag':0}

        let g:Lf_NormalMap = {
                    \ "File":   [["<ESC>", ':exec g:Lf_py "fileExplManager.quit()"<CR>']],
                    \ "Buffer": [["<ESC>", ':exec g:Lf_py "bufExplManager.quit()"<CR>']],
                    \ "Mru":    [["<ESC>", ':exec g:Lf_py "mruExplManager.quit()"<CR>']],
                    \ "Tag":    [["<ESC>", ':exec g:Lf_py "tagExplManager.quit()"<CR>']],
                    \ "Function":    [["<ESC>", ':exec g:Lf_py "functionExplManager.quit()"<CR>']],
                    \ "Colorscheme":    [["<ESC>", ':exec g:Lf_py "colorschemeExplManager.quit()"<CR>']],
                    \ }

    " }

    " Rainbow {
    if isdirectory(expand("~/.vim/plugged/rainbow/"))
        let g:rainbow_active = 1 "0 if you want to enable it later via :RainbowToggle
    endif
    "}

    " vim-airline {
    " Set configuration options for the statusline plugin vim-airline.
    " Use the powerline theme and optionally enable powerline symbols.
    " To use the symbols , , , , , , and .in the statusline
    " segments add the following to your .vimrc.before.local file:
    "   let g:airline_powerline_fonts=1
    " If the previous symbols do not render for you then install a
    " powerline enabled font.

    " See `:echo g:airline_theme_map` for some more choices
    " Default in terminal vim is 'dark'
    if isdirectory(expand("~/.vim/plugged/vim-airline-themes/"))
        if !exists('g:airline_theme')
            let g:airline_theme = 'solarized'
        endif
        if !exists('g:airline_powerline_fonts')
            " Use the default set of separators with a few customizations
            let g:airline_left_sep='›'  " Slightly fancier than '>'
            let g:airline_right_sep='‹' " Slightly fancier than '<'
        endif
    endif
    " }

    " CSyntaxAfter {
        " 高亮括号与运算符等
        au! BufRead,BufNewFile,BufEnter *.{c,cpp,h,java,javascript} call CSyntaxAfter()
        if exists("*CSyntaxAfter()")
            windo call CSyntaxAfter()
        endif
    " }

    " vim-trailing-whitespace {
        " 下列文件类型中的行尾空格tab不高亮显示
        "let g:extra_whitespace_ignored_filetypes = ['unite', 'mkd', 'h', 'hpp', 'c', 'cpp', 'py']
        map <leader><Space> :FixWhitespace<cr>
    " }
    " neocomplcache {
        let g:neocomplcache_enable_at_startup = 1     "vim 启动时启用插件
        " let g:neocomplcache_disable_auto_complete = 1 "不自动弹出补全列表
    " }

    " Omnicppcomplete {
        set completeopt=menu                        "关闭预览窗口
    " }
" }


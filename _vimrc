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
    "  < 编码配置 >
    " -----------------------------------------------------------------------------
    " 注：使用utf-8格式后，软件与程序源码、文件路径不能有中文，否则报错
    set encoding=utf-8                                    "设置gvim内部编码，默认不更改
    set fileencoding=utf-8                                "设置当前文件编码，可以更改，如：gbk（同cp936）
    set fileencodings=ucs-bom,utf-8,gbk,cp936,latin-1     "设置支持打开的文件的编码

    " 文件格式，默认 ffs=dos,unix
    set fileformat=unix                                   "设置新（当前）文件的<EOL>格式，可以更改，如：dos（windows系统常用）
    set fileformats=unix,dos,mac                          "给出文件的<EOL>格式类型

    if (WINDOWS() && has("gui_running"))
        "解决菜单乱码
        source $VIMRUNTIME/delmenu.vim
        source $VIMRUNTIME/menu.vim

        "解决consle输出乱码
        language messages zh_CN.utf-8
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
    "set splitright                  " Puts new vsplit windows to the right of the current
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

    "使用系统剪贴板
    vmap <Leader>c "+y
    nmap <Leader>c "+y
    nmap <Leader>v "+p
    "set term=screen
    nmap <Leader>j :let @/=expand("<cword>")<CR>

" }

" Vim UI {

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

    set backspace=indent,eol,start  " Backspace for dummies
    set linespace=0                 " No extra spaces between rows
    set number                      " Line numbers on
    "set showmatch                   " Show matching brackets/parenthesis
    set incsearch                   " Find as you type search
    set hlsearch                    " Highlight search terms
    set winminheight=0              " Windows can be 0 line high
    set ignorecase                  " Case insensitive search
    set smartcase                   " Case sensitive when uc present
    set wildmenu                    " Show list instead of just completing
    set wildmode=list:longest,full  " Command <Tab> completion, list matches, then longest common part, then all.
    "set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap too
    set scrolljump=5                " Lines to scroll when cursor leaves screen
    set scrolloff=3                 " Minimum lines to keep above and below cursor
    set foldenable                  " Auto fold code
    set foldmethod=manual
    set foldcolumn=1
    " 将尾行的空格,tab等显示出来
    "set list
    "set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace
    " 常规模式下用空格键来开关光标行所在折叠（注：zR 展开所有折叠，zM 关闭所有折叠）

    nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>
    " 自动保存折叠
    "au BufWinLeave * silent mkview
    "au BufWinEnter * silent loadview

" }

" GUI Settings {

    " GVIM- (here instead of .gvimrc)
    if has('gui_running')
        set guioptions-=T       " gvim不包含工具栏
        set guioptions-=m       " gvim不使用菜单栏
        set guioptions-=r       " gvim不显示右边滚动条
        set guioptions-=l       " gvim不显示左边滚动条

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

" }

" Use Plugin Manager Plugs {
silent! call plug#begin('~/.vim/plugged')
        " gtags and gnu global support
        Plug 'vim-scripts/gtags.vim'
        " 提供gtags数据库的无缝更新及连接, 它能自动更新工程的.tag文件
        Plug 'ludovicchabant/vim-gutentags'
        " 提供gtags数据库无缝切换
        Plug 'skywind3000/gutentags_plus'
        " 预览
        Plug 'skywind3000/vim-preview'
        " color
        " Tomorrow-Night-Eighties 这个配色方案在这个包里
        "Plug 'ChrisKempson/Tomorrow-Theme'
        " language specific enhance
        " auto add head-comment in .c file
        " Plug 'vim-scripts/c.vim'
        Plug 'octol/vim-cpp-enhanced-highlight'
        Plug 'vim-scripts/cSyntaxAfter'
        " enhanced std\c++14 highlight
        Plug 'vim-scripts/STL-improved'
        Plug 'bronson/vim-trailing-whitespace'
        " 头文件与源文件相互跳转
        Plug 'tpope/vim-projectionist'

        " 文件/buffer模糊匹配快速切换, 也可显示函数列表
        Plug 'Yggdroot/LeaderF'
        Plug 'vim-airline/vim-airline'
        Plug 'vim-airline/vim-airline-themes'

        Plug 'vim-scripts/std_c.zip'

        " restore_view confict with gutentags to not find ctags
        "Plug 'vim-scripts/restore_view.vim'
        " 异步执行shell命令，可用于编译运行程序
        Plug 'skywind3000/asyncrun.vim'
        " 显示文件与上次提交的差异
        Plug 'mhinz/vim-signify'

        " 文本对象
        Plug 'kana/vim-textobj-user'
        Plug 'kana/vim-textobj-indent'
        Plug 'kana/vim-textobj-syntax'
        Plug 'kana/vim-textobj-function', { 'for':['c', 'cpp', 'vim', 'java'] }
        Plug 'sgur/vim-textobj-parameter'

        " 当前文档按"-"号进入目录
        Plug 'justinmk/vim-dirvish'
        Plug 'tpope/vim-surround'

        " if can't use YCP, take this two instead
        "Plug 'Shougo/neocomplcache.vim'
        "Plug 'vim-scripts/OmniCppComplete'
        Plug 'ycm-core/YouCompleteMe'

        " UltiSnips 只是个引擎，需要搭配预设的代码块才能运转起来
        Plug 'SirVer/ultisnips'
        " 代码块集合
        Plug 'honza/vim-snippets'

        Plug 'tenfyzhong/CompleteParameter.vim'

        " *: 向前搜索，#: 向后搜索
        Plug 'vim-scripts/TxtBrowser'

        "Plug 'vim-scripts/ShowMarks'
        " Ctrl-P or Ctrl-N to complete the word in command mode
        Plug 'vim-scripts/CmdlineComplete'
        " 插入模式下emacs式光标移动命令
        Plug 'tpope/vim-rsi'

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
        set t_Co=256      "在windows中用xshell连接打开vim可以显示色彩
        let g:airline#extensions#tabline#enabled = 1   " 是否打开tabline
        "这个是安装字体后 必须设置此项"
        let g:airline_powerline_fonts = 1
        set laststatus=2  "永远显示状态栏
        let g:airline_theme='bubblegum' "选择主题
        let g:airline#extensions#tabline#enabled=1    "Smarter tab line: 显示窗口tab和buffer
        "let g:airline#extensions#tabline#left_sep = ' '  "separater
        "let g:airline#extensions#tabline#left_alt_sep = '|'  "separater
        "let g:airline#extensions#tabline#formatter = 'default'  "formater
        let g:airline_left_sep = '▶'
        let g:airline_left_alt_sep = '❯'
        let g:airline_right_sep = '◀'
        let g:airline_right_alt_sep = '❮'
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
        let g:extra_whitespace_ignored_filetypes = ['unite', 'mkd', 'h', 'hpp', 'c', 'cpp', 'py']
        map <leader><Space> :FixWhitespace<cr>
    " }
    " neocomplcache {
        let g:neocomplcache_enable_at_startup = 1     "vim 启动时启用插件
        " let g:neocomplcache_disable_auto_complete = 1 "不自动弹出补全列表
    " }

    " Omnicppcomplete {
        set completeopt=menu                        "关闭预览窗口
    " }
    " asyncrun.vim {
        " 自动打开 quickfix window ，高度为 6
        let g:asyncrun_open = 6
        " 任务结束时候响铃提醒
        let g:asyncrun_bell = 1
        " 设置 F10 打开/关闭 Quickfix 窗口
        nnoremap <F10> :call asyncrun#quickfix_toggle(6)<cr>
        " 编译单个文件
        nnoremap <silent> <F9> :AsyncRun gcc "$(VIM_FILEPATH)" -o "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <cr>
        " 按 F5 运行
        " 用双引号引起来避免文件名包含空格，
        " “-cwd=$(VIM_FILEDIR)” 的意思是在文件所在目录运行可执行，后面可执行使用了全路径，避免 linux 下面当前路径加 “./” 而 windows 不需要的跨平台问题。
        " 参数 `-raw` 表示输出不用匹配错误检测模板 (errorformat) ，直接原始内容输出到 quickfix 窗口。
        " 这样你可以一边编辑一边 F9 编译，出错了可以在 quickfix 窗口中按回车直接跳转到错误的位置，编译正确就接着执行。
        nnoremap <silent> <F5> :AsyncRun -raw -cwd=$(VIM_FILEDIR) "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <cr>

        " AsyncRun 识别当前文件的项目目录方式和 gutentags相同，从文件所在目录向上递归，
        " 直到找到名为 “.git”, “.svn”, “.hg”或者 “.root”文件或者目录，如果递归到根目录还没找到，
        " 那么文件所在目录就被当作项目目录，你重新定义项目标志
        let g:asyncrun_rootmarks = ['.svn', '.git', '.root', '_darcs', 'build.xml']

        " 在 AsyncRun 命令行中，用 “<root>” 或者 “$(VIM_ROOT)”来表示项目所在路径
        " 定义按 F7 编译整个项目
        nnoremap <silent> <F7> :AsyncRun -cwd=<root> make <cr>

        " 继续配置用 F8 运行当前项目, 当然，你的 makefile 中需要定义怎么 run
        nnoremap <silent> <F8> :AsyncRun -cwd=<root> -raw make run <cr>
        " 接着按 F6 执行测试
        nnoremap <silent> <F6> :AsyncRun -cwd=<root> -raw make test <cr>
        " 如果你使用了 cmake 的话，还可以照葫芦画瓢，定义 F4 为更新 Makefile 文件，如果不用 cmake 可以忽略
        "nnoremap <silent> <F4> :AsyncRun -cwd=<root> cmake . <cr>

        "if WINDOWS()
        "    " 在 Windows 下使用 -mode=4 选项可以跟 Visual Studio 执行命令行工具一样，弹出一个新的 cmd.exe窗口来运行程序或者项目
        "    nnoremap <silent> <F5> :AsyncRun -cwd=$(VIM_FILEDIR) -mode=4 "$(VIM_FILEDIR)/$(VIM_FILENOEXT)" <cr>
        "    nnoremap <silent> <F8> :AsyncRun -cwd=<root> -mode=4 make run <cr>
        "endif

    " }

    " vim-cpp-enhanced-highlight {
        let g:cpp_class_scope_highlight = 1
        let g:cpp_member_variable_highlight = 1
        let g:cpp_class_decl_highlight = 1
        let g:cpp_concepts_highlight = 1
        let g:cpp_no_function_highlight = 1
    " }

    " vim-signify {
        " `:SignifyDiff`，可以左右分屏对比提交前后记录
        " 强制显示侧边栏
        " set signcolumn=yes
    " }
    "
    " textobject {
        " i, 和 a, ：参数对象，写代码一半在修改，现在可以用 di, 或 ci, 一次性删除/改写当前参数
        " ii 和 ai ：缩进对象，同一个缩进层次的代码，可以用 vii 选中，dii / cii 删除或改写
        " if 和 af ：函数对象，可以用 vif / dif / cif 来选中/删除/改写函数的内容
    " }

    " surround {
    " command mode
    " ds                删除一个配对符号 (delete a surrounding)
    " cs                更改一个配对符号 (change a surrounding)
    " ys                增加一个配对符号 (yank a surrounding)
    " yS                在新的行增加一个配对符号并进行缩进
    " yss               在整行增加一个配对符号
    " ySs/Yss           在整行增加一个配对符号，配对符号单独成行并进行缩进
    " visual mode
    " s                增加一个配对符号
    " S                在整行增加一个配对符号，配对符号单独成行并进行缩进
    "
    " insert mode
    " Ctrl + s                    增加一个配对符号
    " Ctrl +s, Ctrl +s        在整行增加一个配对符号，配对符号单独成行并进行缩进
    " }

    " youcompleteme {
        "关闭自动弹出的原型预览窗口
        set completeopt=menu,menuone
        let g:ycm_add_preview_to_completeopt = 0
        " 关闭诊断信息
        let g:ycm_show_diagnostics_ui = 0
        " 对于 C-family 工程，ycm 需要配置文件 .ycm_extra_conf.py 才能进行语义补全提示(include 库之类的路径)，
        " ycm 尝试从当前目录往上查找读取 .ycm_extra_conf.py 文件导入，最后如果没有找到就使用这个默认配置文件（参考插件例子 ~/.vim/plugged/YouCompleteMe/third_party/ycmd/examples/.ycm_extra_conf.py）。
        " 如果自己工程编译参数，include 不同，可以拷贝默认配置文件修改 flags 后直接放在工程目录下。也可以使用 ycm 提供的 配置文件生成工具
        "let g:ycm_global_ycm_extra_conf= '~/.vim/plugged/YouCompleteMe/third_party/ycmd/examples/.ycm_extra_conf.py'
        let g:ycm_global_ycm_extra_conf= '~/.vim/plugged/YouCompleteMe/third_party/ycmd/examples/.ycm_extra_conf.py'
        "导入工程自己的conf时提示确认
        let g:ycm_confirm_extra_conf = 0
        let g:ycm_server_log_level = 'info'
        " 输入两个字符自动弹出基于符号的补全
        let g:ycm_min_num_identifier_candidate_chars = 2
        let g:ycm_collect_identifiers_from_comments_and_strings = 1
        let g:ycm_complete_in_strings=1
        " 触发语义补全的快捷键
        let g:ycm_key_invoke_completion = '<c-y>'
        set completeopt=menu,menuone
        " 使用 Ctrl+y 主动触发语义补全
        noremap <c-y> <NOP>
        " 修改补全列表配色
        "highlight PMenu ctermfg=0 ctermbg=242 guifg=black guibg=darkgrey
        "highlight PMenuSel ctermfg=242 ctermbg=8 guifg=darkgrey guibg=black
        " 追加语义触发条件，使输入2个字符即可自动触发语义补全
        let g:ycm_semantic_triggers =  {
                    \ 'c,cpp,python,java,go,erlang,perl': ['re!\w{2}'],
                    \ 'cs,lua,javascript': ['re!\w{2}'],
                    \ }
        " 避免编辑白名单外的文件类型时 YCM也在那分析半天
        let g:ycm_filetype_whitelist = {
                    \ "c":1,
                    \ "cpp":1,
                    \ "go":1,
                    \ "python":1,
                    \ "sh":1,
                    \ "zsh":1,
                    \ }

        let g:ycm_filetype_blacklist = {
                    \ 'markdown' : 1,
                    \ 'text' : 1,
                    \ 'pandoc' : 1,
                    \ 'infolog' : 1,
                    \}
        " }
    " }

    " ultisnips {
    "let g:UltiSnipsExpandTrigger = "<c-j>"
    "let g:UltiSnipsJumpForwardTrigger = "<c-b>"
    "let g:UltiSnipsJumpBackwardTrigger="<c-z>"
    function! g:UltiSnips_Complete()
        call UltiSnips#ExpandSnippet()
        if g:ulti_expand_res == 0
            if pumvisible()
                return "\<C-n>"
            else
                call UltiSnips#JumpForwards()
                if g:ulti_jump_forwards_res == 0
                    return "\<TAB>"
                endif
            endif
        endif
        return ""
    endfunction

    function! g:UltiSnips_Reverse()
        call UltiSnips#JumpBackwards()
        if g:ulti_jump_backwards_res == 0
            return "\<C-P>"
        endif

        return ""
    endfunction


    if !exists("g:UltiSnipsJumpForwardTrigger")
        let g:UltiSnipsJumpForwardTrigger = "<tab>"
    endif
    if !exists("g:UltiSnipsJumpBackwardTrigger")
        let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
    endif

    au InsertEnter * exec "inoremap <silent> " . g:UltiSnipsExpandTrigger     . " <C-R>=g:UltiSnips_Complete()<cr>"
    au InsertEnter * exec "inoremap <silent> " .     g:UltiSnipsJumpBackwardTrigger . " <C-R>=g:UltiSnips_Reverse()<cr>"
    " }

    " CompleteParameter.vim {
    inoremap <silent><expr> ( complete_parameter#pre_complete("()")
    smap <c-k> <Plug>(complete_parameter#goto_next_parameter)
    imap <c-k> <Plug>(complete_parameter#goto_next_parameter)
    smap <c-l> <Plug>(complete_parameter#goto_previous_parameter)
    imap <c-l> <Plug>(complete_parameter#goto_previous_parameter)
    " }
" }


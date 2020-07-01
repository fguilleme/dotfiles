" Various options {{{
set number
set norelativenumber

set tildeop
set wrap

set list
set listchars=eol:¬,trail:░,extends:⇁,tab:\ \ ,nbsp:⇹ 
" }}}

"{{{ Mappings
" easily switch between windows
map <C-Up> <C-W><Up>
map <C-DOWN> <C-W><Down>
map <C-Left> <C-W><Left>
map <C-Right> <C-W><Left>

" switch v and <C-V> it is far more logical
nnoremap    v   <C-V>
nnoremap <C-V>     v
vnoremap    v   <C-V>
vnoremap <C-V>     v

" consistent with vim commands
nnoremap Y y$

" Visual shifting (does not exit Visual mode)
vnoremap < <gv
vnoremap > >gv

" Allow using the repeat operator with a visual selection (!)
" http://stackoverflow.com/a/8064607/127816
vnoremap . :normal .<CR>
-
map <S-F4> :cp<CR>
map <F4> :cn<CR>

" For when you forget to sudo.. Really Write the file.
cmap w!! w !sudo tee % >/dev/null

" grep the file fot the word under the cursor
nmap <Leader>ff :vimgrep /<C-R><C-W>/ <C-R>% \| cope 10<CR>

" Don't move on *
" nnoremap * *<c-o>

" Heresy
inoremap <c-a> <esc>I
inoremap <c-e> <esc>A

" Shell ------------------------------------------------------------------- {{{

function! s:ExecuteInShell(command) " {{{
    let command = join(map(split(a:command), 'expand(v:val)'))
    let winnr = bufwinnr('^' . command . '$')
    silent! execute  winnr < 0 ? 'botright vnew ' . fnameescape(command) : winnr . 'wincmd w'
    setlocal buftype=nowrite bufhidden=wipe nobuflisted noswapfile nowrap nonumber
    echo 'Execute ' . command . '...'
    silent! execute 'silent %!'. command
    silent! redraw
    silent! execute 'au BufUnload <buffer> execute bufwinnr(' . bufnr('#') . ') . ''wincmd w'''
    silent! execute 'nnoremap <silent> <buffer> <LocalLeader>r :call <SID>ExecuteInShell(''' . command . ''')<CR>:AnsiEsc<CR>'
    silent! execute 'nnoremap <silent> <buffer> q :q<CR>'
    silent! execute 'AnsiEsc'
    echo 'Shell command ' . command . ' executed.'
endfunction " }}}
command! -complete=shellcmd -nargs=+ Shell call s:ExecuteInShell(<q-args>)
nnoremap <leader>! :Shell 

" }}}
"}}}  
"
"{{{ configure airline
if !exists('g:airline_symbols')
let g:airline_symbols = {}
endif

let g:airline_left_sep = '▶'
let g:airline_right_sep = '◀'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.whitespace = 'Ξ'
let g:airline_detect_whitespace = 0
let g:airline_theme = "dark"
"}}}
"
let $PATH=expand('~/.cabal/bin:').$PATH
let g:haddock_docdir='/home/francois/.cabal'

"{{{ Additional bundles
" NeoBundle 'edsono/vim-sessions' 
NeoBundle "godlygeek/tabular"

" Haskell Bundles
NeoBundle 'travitch/hasksyn'
NeoBundle 'dag/vim2hs'
NeoBundleLazy 'Twinside/vim-haskellConceal', { 'autoload': { 'filetypes': [ 'haskell' ] } }
NeoBundle 'lukerandall/haskellmode-vim'
NeoBundle 'ujihisa/neco-ghc'
NeoBundle 'eagletmt/ghcmod-vim'
" NeoBundle 'Shougo/vimproc'
" NeoBundle 'adinapoli/cumino'
NeoBundle 'bitc/vim-hdevtools'

NeoBundle 'mileszs/ack.vim'
NeoBundle 'kien/ctrlp.vim' " Fuzzy file, buffer, mru, tag, etc finder.
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(o|bin|so)$',
  \ }

NeoBundle 'vim-scripts/rainbow_parentheses.vim' " Better Rainbow Parentheses
" NeoBundle 'vim-scripts/linediff.vim' " Perform an interactive diff on two blocks of text
NeoBundle 'vim-scripts/DoxygenToolkit.vim' " Simplify Doxygen documentation in C, C++, Python.
" NeoBundle 'davidhalter/jedi-vim'
NeoBundle 'mtth/scratch.vim'
let g:haddock_browser = ''

source ~/.vim/bundle/project.tar.gz/plugin/project.vim
map <silent> ,. <Plug>ToggleProject

"space is not working for abbr
"use C-]
" source ~/.vim/bundle/Unicode-Macro-Table/plugin/unicodemacros.vi( 2/17): |vim-haskellConceal| Errorm
source ~/.vim/bundle/Alternate/plugin/a.vim
nmap <A-O> :A<CR>

NeoBundle 'junegunn/fzf' " :cherry_blossom: A command-line fuzzy finder
"}}}

"highlight the word under the cursor and all its occurences
autocmd CursorMoved * exe printf('match WordUnder /\V\<%s\>/', escape(expand('<cword>'), '/\'))

"{{{ YCM 
" autocmd FileType python NeoCompleteLock
" autocmd FileType c NeoCompleteLock
" autocmd FileType cpp NeoCompleteLock

NeoBundle "Valloric/YouCompleteMe"

" let g:ycm_semantic_triggers = {'haskell' : ['.'] }

" let g:UltiSnipsExpandTrigger="<c-j>"
" let g:UltiSnipsJumpForwardTrigger="<c-j>"
" let g:UltiSnipsJumpBackwardTrigger="<c-k>"

" " let g:ycm_filetype_whitelist = { 'c': 1, 'cpp': 1, 'objc': 1, 'python': 1, 'haskell': 1, 'java': 1 }
" " let g:ycm_filetype_whitelist = { 'c': 1, 'cpp': 1, 'objc': 1, 'python': 1, 'haskell':1 }
" let g:ycm_filetype_whitelist = { 'c': 1, 'cpp': 1, 'objc': 1, 'python':1 }
" " let g:ycm_filetype_specific_completion_to_disable = { 'vim': 1, 'haskell': 1 }
"  let g:ycm_filetype_specific_completion_to_disable = { 'vim': 1, 'haskell':1, 'java':1 }
let g:ycm_confirm_extra_conf = 0

" let g:ycm_server_python_interpreter = '/usr/bin/python3'
" let g:ycm_python_binary_path = '/usr/bin/python3'

nmap <F12> :YcmCompleter GoTo <C-R><C-W><CR>
"}}}


"{{{ JAVAComplete
" let targetAndroidJar = '/home/francois/android/android-sdk/platforms/android-21/android.jar'
" if $CLASSPATH =~ ''
"     let $CLASSPATH = targetAndroidJar . ':' . $CLASSPATH
" else
"     let $CLASSPATH = targetAndroidJar
" endif

" NeoBundle 'vim-scripts/javacomplete' " Omni Completion for JAVA

" " configure syntastic to work with java projects
" let g:syntastic_java_javac_classpath = "./bin/classes:~/android/android-sdk/platforms/android-21/*.jar"
"}}}

colorscheme koehler

highlight CursorLine guibg=gray20
highlight CursorLineNr guibg=gray20 guifg=gray90
highlight Conceal guibg=black ctermbg=black
highlight NonText guifg=gray40 ctermfg=0
highlight Folded guibg=gray20  guifg=orange
highlight LineNr guifg=gray ctermfg=0
highlight WordUnder guibg=#102020 ctermbg=8
highlight ColorColumn guibg=gray10 ctermbg=0
highlight Comment guifg=gray60 guibg=gray5 ctermbg=black ctermfg=7
highlight Visual gui=reverse guibg=black ctermbg=0 cterm=reverse
highlight Pmenu guibg=gray10 guifg=yellow
highlight PmenuSel guibg=gray50 guifg=navy
highlight DiffChange ctermfg=white
highlight DiffText ctermfg=yellow
highlight SyntasticErrorLine guibg=darkred
"}}}

" highlight the current line only in normal mode and on the active window {{{
augroup cline
    au!
    au WinLeave,InsertEnter * set nocursorline
    au WinEnter,InsertLeave * set cursorline
augroup END
" }}}

" Make sure Vim returns to the same line when you reopen a file. {{{
" Thanks, Amit
augroup line_return
    au!
    au BufReadPost *
       \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \     execute 'normal! g`"zvzz' |
        \ endif
augroup END
" }}}

" Keep search matches in the middle of the window. {{{
nnoremap n nzzzv
nnoremap N Nzzzv
" }}}

" Highlight Word {{{
"
" This mini-plugin provides a few mappings for highlighting words temporarily.
"
" Sometimes you're looking at a hairy piece of code and would like a certain
" word or two to stand out temporarily.  You can search for it, but that only
" gives you one color of highlighting.  Now you can use <leader>N where N is
" a number from 1-6 to highlight the current word in a specific color.

function! HiInterestingWord(n) " {{{
    " Save our location.
    normal! mz

    " Yank the current word into the z register.
    normal! "zyiw

    " Calculate an arbitrary match ID.  Hopefully nothing else is using it.
    let mid = 86750 + a:n

    " Clear existing matches, but don't worry if they don't exist.
    silent! call matchdelete(mid)

    " Construct a literal pattern that has to match at boundaries.
    let pat = '\V\<' . escape(@z, '\') . '\>'

    " Actually match the words.
    call matchadd("InterestingWord" . a:n, pat, 1, mid)

    " Move back to our original location.
    normal! `z
    delmarks z
endfunction " }}}

" Mappings {{{

nnoremap <silent> <leader>1 :call HiInterestingWord(1)<cr>
nnoremap <silent> <leader>2 :call HiInterestingWord(2)<cr>
nnoremap <silent> <leader>3 :call HiInterestingWord(3)<cr>
nnoremap <silent> <leader>4 :call HiInterestingWord(4)<cr>
nnoremap <silent> <leader>5 :call HiInterestingWord(5)<cr>
nnoremap <silent> <leader>6 :call HiInterestingWord(6)<cr>

" }}}
" Default Highlights {{{

hi def InterestingWord1 guifg=#000000 ctermfg=16 guibg=#ffa724 ctermbg=214
hi def InterestingWord2 guifg=#000000 ctermfg=16 guibg=#aeee00 ctermbg=154
hi def InterestingWord3 guifg=#000000 ctermfg=16 guibg=#8cffba ctermbg=121
hi def InterestingWord4 guifg=#000000 ctermfg=16 guibg=#b88853 ctermbg=137
hi def InterestingWord5 guifg=#000000 ctermfg=16 guibg=#ff9eb8 ctermbg=211
hi def InterestingWord6 guifg=#000000 ctermfg=16 guibg=#ff2c4b ctermbg=195

" }}}
" }}}

" Synstack {{{

" Show the stack of syntax hilighting classes affecting whatever is under the
" cursor.
function! SynStack()
  echo join(map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")'), " > ")
endfunc

nnoremap <F7> :call SynStack()<CR>
"}}}

" IndentGuides {{{
if 0
    NeoBundle "nathanaelkane/vim-indent-guides"
    let g:indent_guides_enable_on_vim_startup = 1
    let g:indent_guides_auto_colors=1
    let g:indent_guides_start_level=2
    let g:indent_guides_guide_size=1
    let g:indent_guides_auto_colors = 0

    autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd guibg=gray10 ctermbg=8
    autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=gray20 ctermbg=0
else
    NeoBundle 'Yggdroot/indentLine' " A vim plugin to display the indention 
    let g:indentLine_char = '│'
    let g:indentLine_enabled = 1
    autocmd VimEnter,Colorscheme * :IndentLinesEnable
endif
" }}}

" Ack {{{
let g:ackprg = 'ag --nogroup --nocolor --column'
let g:ackhighlight = 1
NeoBundle 'beyondgrep/ack3' " ack is a grep-like search tool optimized for source code.
" }}}

noremap <silent> <leader>/ :execute 'vimgrep /'.@/.'/g %'<CR>:copen<CR>
noremap <silent> <TAB> %

" execute the current line
vnoremap  <silent> <leader>: "yy:execute @@<CR>

" au VimLeave * execute 'mksession!  $PWD/.vimsession'<CR>sleep 2<CR>

" au VimEnter * 
"     \ if argc() == 0 | 
"     \   if filereadable($PWD . '/Session.vim') | 
"     \       source Session.vim |
"     \       source ~/.vimrc | 
"     \   endif |
"     " \   if filereadable('projrc') | 
"     " \       exec Project('projrc') | 
"     " \   endif |
"     \ endif

" autocmd BufEnter *.py :setl wrap
" autocmd BufEnter *.hs :IndentLinesReset
" autocmd BufEnter *.py :IndentLinesReset

" GitGutter colors {{{
highlight SignColumn guibg=gray10
highlight GitGutterAddDefault guibg=gray10
highlight GitGutterChangeDefault guibg=gray10
highlight GitGutterChangeLineDefault guibg=gray10
highlight GitGutterDeleteDefault guibg=gray10
" GitGutter colors }}}

" so we get the mouse inside tmux
set mouse=a

" AckMotion {{{
nnoremap <silent> <leader>A :set opfunc=<SID>AckMotion<CR>g@
xnoremap <silent> <leader>A :<C-U>call <SID>AckMotion(visualmode())<CR>
 
function! s:CopyMotionForType(type)
    if a:type ==# 'v'
        silent execute "normal! `<" . a:type . "`>y"
    elseif a:type ==# 'char'
        silent execute "normal! `[v`]y"
    endif
endfunction
 
function! s:AckMotion(type) abort
    let reg_save = @@
 
    call s:CopyMotionForType(a:type)
 
    execute "normal! :Ack! --literal " . shellescape(@@) . "\<cr>"
 
    let @@ = reg_save
endfunction
" AckMotion }}}

vmap <F8> :!clang-format -style="{BasedOnStyle: LLVM, IndentWidth: 8, UseTab: true, TabWidth: 8, SpacesInParentheses: true }"<CR>

let g:syntastic_auto_loc_list=1
let g:airline_section_warning=0
let g:airline_section_error=0
let g:airline_section_b=0

let g:vinarise_detect_large_file_size = 0

set guifont=DejaVu\ Sans\ Mono\ 11

" if a vimrc file is present in the current dir load it
if filereadable("vimrc")
source vimrc
endif

if filereadable('tags')
set tags=$PWD/tags
endif

" let g:syntastic_java_javac_classpath = '/home/francois/android/du9/out/target/common/obj/JAVA_LIBRARIES/bouncycastle_intermediates/classes.jar:/home/francois/android/du9/out/target/common/obj/JAVA_LIBRARIES/conscrypt_intermediates/classes.jar:/home/francois/android/du9/out/target/common/obj/JAVA_LIBRARIES/core-libart_intermediates/classes.jar:/home/francois/android/du9/out/target/common/obj/JAVA_LIBRARIES/ext_intermediates/classes.jar:/home/francois/android/du9/out/target/common/obj/JAVA_LIBRARIES/framework_intermediates/classes.jar:/home/francois/android/du9/out/target/common/obj/JAVA_LIBRARIES/okhttp_intermediates/classes.jar:/home/francois/android/du9/out/target/common/obj/JAVA_LIBRARIES/telephony-common_intermediates/classes.jar:/home/francois/android/du9/out/target/common/obj/JAVA_LIBRARIES/voip-common_intermediates/classes.jar:'
" vim: foldmethod=marker

" Various options {{{
set number
set norelativenumber

set tildeop
set wrap

set list
set listchars=eol:¬,trail:░,extends:⇁,tab:\ \ ,nbsp:⇹ 
set backspace=indent,start
" }}}

"{{{ Mappings
" easily switch between windows
map <C-Up> <C-W><Up>
map <C-DOWN> <C-W><Down>
map <C-Left> <C-W><Left>
map <C-Right> <C-W><Left>

" switch v and <C-V> it is far more logical
if !exists('g:vscode')
nnoremap    v   <C-V>
nnoremap <C-V>     v
vnoremap    v   <C-V>
vnoremap <C-V>     v
endif

" consistent with vim commands
nnoremap Y y$

" Visual shifting (does not exit Visual mode)
vnoremap < <gv
vnoremap > >gv

" Allow using the repeat operator with a visual selection (!)
" http://stackoverflow.com/a/8064607/127816
vnoremap . :normal .<CR>
-
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

"highlight the word under the cursor and all its occurences
autocmd CursorMoved * exe printf('match WordUnder /\V\<%s\>/', escape(expand('<cword>'), '/\'))

colorscheme  industry

highlight CursorLine guibg=gray10
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
function! SynStack()
  echo join(map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")'), " > ")
endfunc

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

nnoremap <silent> ,1 :call HiInterestingWord(1)<cr>
nnoremap <silent> ,2 :call HiInterestingWord(2)<cr>
nnoremap <silent> ,3 :call HiInterestingWord(3)<cr>
nnoremap <silent> ,4 :call HiInterestingWord(4)<cr>
nnoremap <silent> ,5 :call HiInterestingWord(5)<cr>
nnoremap <silent> ,6 :call HiInterestingWord(6)<cr>

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
    let g:indent_guides_enable_on_vim_startup = 1
    let g:indent_guides_auto_colors=1
    let g:indent_guides_start_level=2
    let g:indent_guides_guide_size=1
    let g:indent_guides_auto_colors = 0

    autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd guibg=gray10 ctermbg=8
    autocmd VimEnter,Colorscheme * :hi IndentGuidesEven guibg=gray20 ctermbg=0
else
    let g:indentLine_char = '│'
    let g:indentLine_enabled = 1
    " autocmd VimEnter,Colorscheme * :IndentLinesEnable
endif
" }}}

noremap <silent> <leader>/ :execute 'vimgrep /'.@/.'/g %'<CR>:copen<CR>

" execute the current line
vnoremap  <silent> <leader>: "yy:execute @@<CR>

" if a vimrc file is present in the current dir load it
if filereadable("vimrc")
source vimrc
endif

if filereadable('tags')
set tags=$PWD/tags
endif

" GitGutter colors {{{
highlight SignColumn guibg=gray10
highlight GitGutterAddDefault guibg=gray10
highlight GitGutterChangeDefault guibg=gray10
highlight GitGutterChangeLineDefault guibg=gray10
highlight GitGutterDeleteDefault guibg=gray10
" GitGutter colors }}}

" so we get the mouse inside tmux
set mouse=a

hi! Normal ctermbg=NONE guibg=None
hi! NonText ctermbg=NONE guibg=NONE

" Make a dir if no exists {{{
function! MakeDirIfNoExists(path)
    if !isdirectory(expand(a:path))
        call mkdir(expand(a:path), "p")
    endif
endfunction
" }}}

" Searching {{{
set incsearch                   " incremental searching
set showmatch                   " show pairs match
set hlsearch                    " highlight search results
set smartcase                   " smart case ignore
set ignorecase                  " ignore case letters
" }}}

" History and permanent undo levels {{{
set history=1000
set undofile
set undoreload=1000
" }}}

" Backups {{{
set backup
set noswapfile
" set backupdir=$HOME/.vim/tmp/backup//
" set undodir=$HOME/.vim/tmp/undo//
" set directory=$HOME/.vim/tmp/swap//
" set viminfo+=n$HOME/.vim/tmp/viminfo
" }}}

" make this dirs if no exists previously
" silent! call MakeDirIfNoExists(&undodir)
" silent! call MakeDirIfNoExists(&backupdir)
" silent! call MakeDirIfNoExists(&directory)

set textwidth=0
set colorcolumn=100
set number
set relativenumber

set formatprg=clang-format-10

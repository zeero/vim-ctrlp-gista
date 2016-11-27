" =============================================================================
" File:          autoload/ctrlp/gista.vim
" Description:   CtrlP extension for GitHub Gist with vim-gista.
" =============================================================================

" To load this extension into ctrlp, add this to your vimrc:
"
"     let g:ctrlp_extensions = ['gista']
"
" Where 'gista' is the name of the file 'gista.vim'
"
" For multiple extensions:
"
"     let g:ctrlp_extensions = [
"         \ 'my_extension',
"         \ 'my_other_extension',
"         \ ]

" Load guard
if ( exists('g:loaded_ctrlp_gista') && g:loaded_ctrlp_gista )
  \ || v:version < 700 || &cp
  finish
endif
let g:loaded_ctrlp_gista = 1


" Add this extension's settings to g:ctrlp_ext_vars
"
" Required:
"
" + init: the name of the input function including the brackets and any
"         arguments
"
" + accept: the name of the action function (only the name)
"
" + lname & sname: the long and short names to use for the statusline
"
" + type: the matching type
"   - line : match full line
"   - path : match full line like a file or a directory path
"   - tabs : match until first tab character
"   - tabe : match until last tab character
"
" Optional:
"
" + enter: the name of the function to be called before starting ctrlp
"
" + exit: the name of the function to be called after closing ctrlp
"
" + opts: the name of the option handling function called when initialize
"
" + sort: disable sorting (enabled by default when omitted)
"
" + specinput: enable special inputs '..' and '@cd' (disabled by default)
"
call add(g:ctrlp_ext_vars, {
  \ 'init': 'ctrlp#gista#init()',
  \ 'accept': 'ctrlp#gista#accept',
  \ 'lname': 'gista',
  \ 'sname': 'gst',
  \ 'type': 'line',
  \ 'enter': 'ctrlp#gista#enter()',
  \ 'exit': 'ctrlp#gista#exit()',
  \ 'opts': 'ctrlp#gista#opts()',
  \ 'sort': 0,
  \ 'specinput': 0,
  \ })

let s:gista_options = {
\ 'lookup':   '',
\ 'username': 0,
\ 'apiname':  '',
\}

let s:opener = {
\ 'e': 'edit',
\ 'v': 'vsplit',
\ 'h': 'split',
\ 't': 'tabnew',
\}

let s:nocache = 0
let s:cache_forced = 2

" Provide a list of strings to search in
"
" Return: a Vim's List
"
function! ctrlp#gista#init()
  let session = gista#client#session(s:gista_options)
  try
    if session.enter()
      let result = gista#command#list#call(s:gista_options)
    else
      return []
    endif
  finally
    call session.exit()
  endtry
  " get gists
  let gists = result.index.entries
  call sort(gists, 's:sort_by_updated')

  " make gists list
  let list = []
  for gist in gists
    let filename = get(keys(gist.files), 0)
    let padding = &columns - strdisplaywidth(filename) - strdisplaywidth(gist.description) - 24 - (shiftwidth() * 2)
    call add(list, printf("%s\t%s%" . padding . "s\t[%-20s]", filename, gist.description, '', gist.id))
  endfor

  " highlight
  call ctrlp#hicheck('CtrlPGistaFilename', 'Identifier')
  syn match CtrlPGistaFilename ' [^\t]*\ze\t'
  call ctrlp#hicheck('CtrlPGistaDesc', 'Comment')
  syn match CtrlPGistaDesc '\t\zs[^\t]*'
  call ctrlp#hicheck('CtrlPGistaId', 'Special')
  syn match CtrlPGistaId '\t\zs[^\t]*$'

  return list
endfunction
function! s:sort_by_updated(i1, i2) "{{{
  let time1 = a:i1.updated_at
  let time2 = a:i2.updated_at
  return time1 == time2 ? 0 : time1 < time2 ? 1 : -1
endfunction "}}}


" The action to perform on the selected string
"
" Arguments:
"  a:mode   the mode that has been chosen by pressing <cr> <c-v> <c-t> or <c-x>
"           the values are 'e', 'v', 't' and 'h', respectively
"  a:str    the selected string
"
function! ctrlp#gista#accept(mode, str)
  call ctrlp#exit()
  let gist_id = matchstr(get(split(a:str, "\t"), 2), '[0-9a-z]\+')
  let bufname = gista#command#open#bufname({
  \ 'gistid': gist_id,
  \ 'cache': s:nocache,
  \ 'verbose': 0,
  \})
  execute printf('%s %s', s:opener[a:mode], bufname)
endfunction


" (optional) Do something before enterting ctrlp
function! ctrlp#gista#enter()
endfunction


" (optional) Do something after exiting ctrlp
function! ctrlp#gista#exit()
endfunction


" (optional) Set or check for user options specific to this extension
function! ctrlp#gista#opts()
endfunction


" Give the extension an ID
let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

" Allow it to be called later
function! ctrlp#gista#id()
  return s:id
endfunction


" Create a command to directly call the new search type
"
" Put this in vimrc or plugin/gista.vim
" command! CtrlPGista call ctrlp#init(ctrlp#gista#id())


" vim:nofen:fdl=0:ts=2:sw=2:sts=2

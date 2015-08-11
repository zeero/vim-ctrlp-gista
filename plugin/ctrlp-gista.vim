" ctrlp-gista - CtrlP extension for GitHub Gist with vim-gista.

if exists('g:loaded_vim_ctrlp_gista')
  finish
endif
let g:loaded_vim_ctrlp_gista = 1

let s:save_cpo = &cpo
set cpo&vim

" Variables

" Commands
command! -bar CtrlPGista call ctrlp#init(ctrlp#gista#id())

" Keymaps


let &cpo = s:save_cpo
unlet s:save_cpo

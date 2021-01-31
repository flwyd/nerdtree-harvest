" Copyright 2021 Google LLC
"
" Licensed under the Apache License, Version 2.0 (the "License");
" you may not use this file except in compliance with the License.
" You may obtain a copy of the License at
"
"     https://www.apache.org/licenses/LICENSE-2.0
"
" Unless required by applicable law or agreed to in writing, software
" distributed under the License is distributed on an "AS IS" BASIS,
" WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
" See the License for the specific language governing permissions and
" limitations under the License.

" File: nerdtree_plugin/yank_mappings.vim
" Author: Trevor Stone
" Description: NERDTree plugin mappings for yanking a path to a register with
" filename modifiers applied.  For example, yh yanks basedir path, like %:h.
if exists('g:nerdtree_harvest_yank_loaded') || version < 703
  finish
endif
let g:nerdtree_harvest_yank_loaded = 1

" yy, YY use the previous yank modifier, or relative path if it's the first
" yank action.
let s:lastModifier = ':.'

" Yank node's path into selected register with modifier (e.g. ':p') applied.
" opts contains setreg() options.
function! s:yankModified(modifier, opts, node) abort
  " If switching from characterwise y-yank to linewise Y-yank, insert a line
  " break at the end of the existing register value
  if a:opts =~# '[lV]' && getregtype(v:register) !=# 'V' && !empty(getreg(v:register))
    call setreg(v:register, '', 'Va')
  endif
  call setreg(v:register, fnamemodify(a:node.path.str(), a:modifier), a:opts)
endfunction

function! s:yankMapping(opts, node) abort
  let l:op = nerdtreeharvest#readOperator()
  let l:mod = l:op ==? 'y' ? s:lastModifier : nerdtreeharvest#modifier(l:op)
  if empty(l:mod)
    call nerdtreeharvest#ringBell()
  else
    let s:lastModifier = l:mod
    call s:yankModified(l:mod, a:opts, a:node)
  endif
endfunction

" Yanks a modified path characterwise, overwriting register contents.
function! NERDTreeHarvest_yank(node) abort
  call s:yankMapping('v', a:node)
endfunction

" Yanks a modified path linewise, appending to register contents.
function! NERDTreeHarvest_Yank(node) abort
  call s:yankMapping('Va', a:node)
endfunction

" Lowercase y yanks a path characterwise and overwrites the register.
call NERDTreeAddKeyMap({
    \ 'key': 'y',
    \ 'callback': 'NERDTreeHarvest_yank',
    \ 'quickhelpText': 'yank with modifier',
    \ 'scope': 'Node'})
" Lowercase y yanks a path linewise and appends to the register.
call NERDTreeAddKeyMap({
    \ 'key': 'Y',
    \ 'callback': 'NERDTreeHarvest_Yank',
    \ 'quickhelpText': 'append with modifier',
    \ 'scope': 'Node'})

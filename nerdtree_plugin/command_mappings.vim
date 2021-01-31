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

" File: nerdtree_plugin/command_mappings.vim
" Author: Trevor Stone
" Description: NERDTree plugin mappings for starting an ex command with a
" trailing path.  Uses ! for shell (`:! path`) and ; for Ex (`: path`).
if exists('g:nerdtree_harvest_command_loaded') || version < 703
  finish
endif
let g:nerdtree_harvest_command_loaded = 1

" ;; and !! use the previous modifier for that command type, or relative path
" if it's the first invocation of that mapping.
let s:lastModifier = {';': ':.', '!': ':.'}

" Starts an Ex command (with prefix), inserts path, moves to the start.
function! s:startCommand(prefix, modifier, node) abort
  let l:path = fnamemodify(a:node.path.str(), a:modifier)
  if a:prefix ==# '!'
    let l:path = shellescape(l:path, 1)
  else
    let l:path = fnameescape(l:path)
  endif
  call feedkeys(':' . a:prefix . ' ' . l:path . "\<Home>", 'n')
  if len(a:prefix) > 0
    call feedkeys(repeat("\<Right>", len(a:prefix)), 'n')
  endif
endfunction

function! s:commandMapping(mapping, prefix, node) abort
  if v:count1 > 1
    echo 'Cannot use a count with ' . a:mapping
    return
  endif
  let l:op = nerdtreeharvest#readOperator()
  let l:mod = l:op ==# a:mapping ? s:lastModifier[a:mapping] : nerdtreeharvest#modifier(l:op)
  if empty(l:mod)
    call nerdtreeharvest#ringBell()
  else
    let s:lastModifier[a:mapping] = l:mod
    call s:startCommand(a:prefix, l:mod, a:node)
  endif
endfunction

" Starts an ex command, with modified path escaped.
function! NERDTreeHarvest_ex(node) abort
  call s:commandMapping(';', '', a:node)
endfunction

" Starts a shell command, with modified path quote-escaped.
function! NERDTreeHarvest_shell(node) abort
  call s:commandMapping('!', '!', a:node)
endfunction

" ; starts an ex command line (:) with modified path at the end.
call NERDTreeAddKeyMap({
    \ 'key': ';',
    \ 'callback': 'NERDTreeHarvest_ex',
    \ 'quickhelpText': 'start ex command',
    \ 'scope': 'Node'})
" . starts a shell command line (:!) with modified path at the end.
call NERDTreeAddKeyMap({
    \ 'key': '!',
    \ 'callback': 'NERDTreeHarvest_shell',
    \ 'quickhelpText': 'start shell command',
    \ 'scope': 'Node'})

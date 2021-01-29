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

" NERDTree plugin mappings for yanking a path to register " with filename
" modifiers applied.  For example, yh yanks basedir path, like %:h.
if exists('g:nerdtree_harvest_yank_loaded') || version < 703
  finish
endif
let g:nerdtree_harvest_yank_loaded = 1

" Yank node's path into selected register with modifier (e.g. ':p') applied.
function! s:yankModified(modifier, node) abort
  eval setreg(v:register, fnamemodify(a:node.path.str(), a:modifier))
endfunction

" Declare a NERDTree mapping to yank with modifier applied.
function! s:addYankMap(mapping, modifier, name, help) abort
  if has('lambda')
    let l:Func = {node -> s:yankModified(a:modifier, node)}
  else
    let l:Func = 'NERDTreeYank_' . a:name
    execute "function!" l:Func . "(node) abort \n"
      \ "call s:yankModified('" . a:modifier . "', a:node) \n"
      \ "endfunction"
  endif
  call NERDTreeAddKeyMap({
    \ 'key': a:mapping,
    \ 'callback': l:Func,
    \ 'quickhelpText': a:help,
    \ 'scope': 'Node'})
endfunction

call s:addYankMap('yp', ':p', 'yank_absolute', 'yank absolute path')
call s:addYankMap('y~', ':~', 'yank_homedir', 'yank homedir-relative path')
call s:addYankMap('y.', ':.', 'yank_relative', 'yank relative path')
call s:addYankMap('yh', ':h', 'yank_head', 'yank parent path')
call s:addYankMap('yt', ':t', 'yank_tail', 'yank filename')
call s:addYankMap('yr', ':t:r', 'yank_root', 'yank root filename')
call s:addYankMap('ye', ':e', 'yank_extension', 'yank filename extension')

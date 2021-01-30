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
function! s:yankModified(modifier, opts, node) abort
  " If switching from characterwise y-yank to linewise Y-yank, insert a line
  " break at the end of the existing register value
  if a:opts =~# '[lV]' && getregtype(v:register) !=# 'V' && !empty(getreg(v:register))
    call setreg(v:register, '', 'Va')
  endif
  call setreg(v:register, fnamemodify(a:node.path.str(), a:modifier), a:opts)
endfunction

" Declare a NERDTree mapping to yank with modifier applied.
function! s:addYankMap(mapping, modifier, opts, name, help) abort
  if has('lambda')
    let l:Func = {node -> s:yankModified(a:modifier, a:opts, node)}
  else
    let l:Func = 'NERDTreeHarvestYank_' . a:name
    execute printf("function! %s(node) abort\n" .
      \ "call s:yankModified('%s', '%s', a:node)\n endfunction",
      \ l:Func, a:modifier, a:opts)
  endif
  call NERDTreeAddKeyMap({
    \ 'key': a:mapping,
    \ 'callback': l:Func,
    \ 'quickhelpText': a:help,
    \ 'scope': 'Node'})
endfunction

" Lowercase y mappings set register characterwise and overwrite unless the
" user specifies a capital register ("Ryp appends to register r)
call s:addYankMap('yp', ':p', 'v', 'yank_absolute', 'yank absolute path')
call s:addYankMap('y~', ':~', 'v', 'yank_homedir', 'yank homedir-relative path')
call s:addYankMap('y.', ':.', 'v', 'yank_relative', 'yank relative path')
call s:addYankMap('yh', ':h', 'v', 'yank_head', 'yank parent path')
call s:addYankMap('yt', ':t', 'v', 'yank_tail', 'yank filename')
call s:addYankMap('yr', ':t:r', 'v', 'yank_root', 'yank root filename')
call s:addYankMap('ye', ':e', 'v', 'yank_extension', 'yank filename extension')
" Uppercase Y mappings set register linewise and append even if the user
" specifies a lowercase register ("rYp does not overwrite register r)
call s:addYankMap('Yp', ':p', 'Va', 'Yank_absolute', 'append absolute path')
call s:addYankMap('Y~', ':~', 'Va', 'Yank_homedir', 'append homedir-relative path')
call s:addYankMap('Y.', ':.', 'Va', 'Yank_relative', 'append relative path')
call s:addYankMap('Yh', ':h', 'Va', 'Yank_head', 'append parent path')
call s:addYankMap('Yt', ':t', 'Va', 'Yank_tail', 'append filename')
call s:addYankMap('Yr', ':t:r', 'Va', 'Yank_root', 'append root filename')
call s:addYankMap('Ye', ':e', 'Va', 'Yank_extension', 'append filename extension')

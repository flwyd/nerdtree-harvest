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

" NERDTree plugin mappings for starting an ex command with a trailing path.
" Uses ! for shell (`:! path`) and . for Ex (`: path`).
if exists('g:nerdtree_harvest_command_loaded') || version < 700
  finish
endif
let g:nerdtree_harvest_command_loaded = 1

" Starts an Ex command (with prefix), inserts path, moves to the start.
function! s:startCommand(prefix, modifier, node) abort
  let l:path = fnamemodify(a:node.path.str(), a:modifier)
  if a:prefix ==# '!'
    let l:path = shellescape(l:path, 1)
  else
    let l:path = fnameescape(l:path)
  endif
  eval feedkeys(':' . a:prefix . ' ' . l:path . "\<Home>", 'n')
  if len(a:prefix) > 0
    eval feedkeys(repeat("\<Right>", len(a:prefix)), 'n')
  endif
endfunction

" Declare a NERDTree mapping to start a command with prefix.
function! s:addCommandMap(mapping, prefix, modifier, name, help) abort
  if has('lambda')
    let l:Func = {node -> s:startCommand(a:prefix, a:modifier, node)}
  else
    let l:Func = 'NERDTreeStartCommand_' . a:name
    execute "function!" l:Func . "(node) abort \n"
      \ "call s:startCommand('" . a:prefix . "','" . a:modifier . "',a:node) \n"
      \ "endfunction"
  endif
  call NERDTreeAddKeyMap({
    \ 'key': a:mapping,
    \ 'callback': l:Func,
    \ 'quickhelpText': a:help,
    \ 'scope': 'Node'})
endfunction

call s:addCommandMap('!p', '!', ':p', 'shell_absolute', 'shell with absolute path')
call s:addCommandMap('!~', '!', ':~', 'shell_homedir', 'shell with homedir-relative path')
call s:addCommandMap('!.', '!', ':.', 'shell_relative', 'shell with relative path')
call s:addCommandMap('!h', '!', ':h', 'shell_head', 'shell with parent path')
call s:addCommandMap('!t', '!', ':t', 'shell_tail', 'shell with filename')
call s:addCommandMap('!r', '!', ':t:r', 'shell_root', 'shell with root filename')
call s:addCommandMap('!e', '!', ':e', 'shell_extension', 'shell with filename extension')

call s:addCommandMap('.p', '', ':p', 'ex_absolute', 'ex command with absolute path')
call s:addCommandMap('.~', '', ':~', 'ex_homedir', 'ex command with homedir-relative path')
call s:addCommandMap('..', '', ':.', 'ex_relative', 'ex command with relative path')
call s:addCommandMap('.h', '', ':h', 'ex_head', 'ex command with parent path')
call s:addCommandMap('.t', '', ':t', 'ex_tail', 'ex command with filename')
call s:addCommandMap('.r', '', ':t:r', 'ex_root', 'ex command with root filename')
call s:addCommandMap('.e', '', ':e', 'ex_extension', 'ex command with filename extension')

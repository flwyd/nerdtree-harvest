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

" File: nerdtreeharvest.vim
" Author: Trevor Stone
" Description: Functions to support nerdtree-harvest plugin mappings.

""
" @section Introduciton, intro
" @order intro mappings
" NERD Tree Harvest is a plugin which adds mappings to the |NERDTree| directory
" browser to "harvest" file paths by yanking to registers or to ex or shell
" command lines.  Four mappings are created, `y` `Y` `;` `!`, each of which
" reads one or more additional characters to determine a modification to the
" path.  Modifiers are based on |filename-modifiers| and summarized in the
" following table. >
"   Key | Name      | Modification
"   --- | --------- | ------------
"   `.` | relative  | `:.` File path from current working directory
"   `~` | home      | `:~` File path from home directory, or absolute
"   `p` | absolute  | `:p` Absolute path from filesystem root
"   `h` | head      | `:h` Path without the last component (parent directory)
"   `H` | rel+head  | `:.:h` Relative path to parent directory
"   `t` | tail      | `:t` Final path component (file name)
"   `r` | root      | `:r` Last extension removed (`/a/b.c` -> `/a/b`)
"   `R` | tail+root | `:t:r` Tail with last extension removed (`/a/b.c` -> `b`)
"   `e` | extension | `:e` Last extension of the file name (`/a/b.c` -> `c`)
"   `:` | modifier  | `:` Arbitrary modifier, type enter to end e.g. `:~:h<CR>`
"   `?` | help      | Echo a list of modifiers, continue reading next one
" <
" Mappings can also be repeated (`yy` `YY` `;;` `!!`) to reuse the previous
" modifier for that mapping type, e.g. `!h` starts a shell command with the
" parent directory and then `!!` will do the same.  `yy` and `YY` share the
" same previous modifier state.
"
" Additional documentation and the latest version of this plugin can be found
" at https://github.com/flwyd/nerdtree-harvest

""
" @section Mappings, mappings
" The following mappings are added to |NERDTree| buffers. |Yank| mappings accept
" |registers| as a prefix and default to the unnamed register. Pressing `?`
" after the first character of a mapping will show available modifier keys.
" If the screen is wide enough, modifier names will be listed after each
" modifier key; if the screen is too narrow only the keys are shown, but a
" second `?` will show the full explanation.
"
" *nerdtree-harvest-y* *nerdtree-harvest-yank*
"
" `y` mappings yank the modified path into the given register |characterwise|,
" overwriting the current register contents. >
"   y.  Yank the relative file path
"   y~  Yank the file path relative to your home directory
"   yp  Yank the absolute path from the filesystem root
"   yh  Yank the parent directory's path
"   yH  Yank the parent directory's relative path
"   yt  Yank the final path component, i.e. the file name
"   yr  Yank the path, with its last extension removed
"   yR  Yank the final path component, with its last extension removed
"   ye  Yank the last extension of the file
"   y:  Enter additional |filename-modifiers| keys, end with <CR>
"   yy  Yank with the previous yank modifier
"   y?  Show a list of modifiers, continue reading
" <
"
" *nerdtree-harvest-Y* *nerdtree-harvest-Yank*
"
" `Y` mappings yank the modified path into the given register |linewise|,
" appending to the current register contents. `Y` can thus be used to collect
" several files of interest from the tree and later pasted into a buffer. >
"   Y.  Yank the relative file path
"   Y~  Yank the file path relative to your home directory
"   Yp  Yank the absolute path from the filesystem root
"   Yh  Yank the parent directory's path
"   YH  Yank the parent directory's relative path
"   Yt  Yank the final path component, i.e. the file name
"   Yr  Yank the path, with its last extension removed
"   YR  Yank the final path component, with its last extension removed
"   Ye  Yank the last extension of the file
"   Y:  Enter additional |filename-modifiers| keys, end with <CR>
"   YY  Yank with the previous yank modifier
"   Y?  Show a list of modifiers, continue reading
" <
"
" *nerdtree-harvest-;* *nerdtree-harvest-command*
"
" `;` mappings start an Ex command (|:|) with the escaped, modified path and
" move the cursor to the beginning of the command. >
"   ;.  Ex command with the relative file path
"   ;~  Ex command with the file path relative to your home directory
"   ;p  Ex command with the absolute path from the filesystem root
"   ;h  Ex command with the parent directory's path
"   ;H  Ex command with the parent directory's relative path
"   ;t  Ex command with the final path component, i.e. the file name
"   ;r  Ex command with the path, with its last extension removed
"   ;R  Ex command with the final path component, with last extension removed
"   ;e  Ex command with the last extension of the file
"   ;:  Enter additional |filename-modifiers| keys, end with <CR>
"   ;;  Ex command with the previous Ex modifier
"   ;?  Show a list of modifiers, continue reading
" <
"
" *nerdtree-harvest-!* *nerdtree-harvest-shell*
"
" `!` mappings start a Shell command (|:!|) with the quoted, escaped, modified
" path and move cursor to the beginning of the command. >
"   !.  Shell command with the relative file path
"   !~  Shell command with the file path relative to your home directory
"   !p  Shell command with the absolute path from the filesystem root
"   !h  Shell command with the parent directory's path
"   !H  Shell command with the parent directory's relative path
"   !t  Shell command with the final path component, i.e. the file name
"   !r  Shell command with the path, with its last extension removed
"   !R  Shell command with the final path component, with last extension removed
"   !e  Shell command with the last extension of the file
"   !:  Enter additional |filename-modifiers| keys, end with <CR>
"   !!  Shell command with the previous shell modifier
"   !?  Show a list of modifiers, continue reading
" <

if exists('g:nerdtree_harvest_functions_loaded') || version < 703
  finish
endif
let g:nerdtree_harvest_functions_loaded = 1

let s:operators = {
    \ '.': {'name': 'relative', 'modifier': ':.'},
    \ '~': {'name': 'home', 'modifier': ':~'},
    \ 'p': {'name': 'absolute', 'modifier': ':p'},
    \ 'h': {'name': 'head', 'modifier': ':h'},
    \ 'H': {'name': 'rel+head', 'modifier': ':.:h'},
    \ 't': {'name': 'tail', 'modifier': ':t'},
    \ 'r': {'name': 'root', 'modifier': ':r'},
    \ 'R': {'name': 'tail+root', 'modifier': ':t:r'},
    \ 'e': {'name': 'extension', 'modifier': ':e'},
    \ ':': {'name': 'modifier'},
    \ }
let s:helporder = ['.', '~', 'p', 'h', 'H', 't', 'r', 'R', 'e', ':']

function! nerdtreeharvest#getOp(operator) abort
  if has_key(s:operators, a:operator)
    return s:operators[a:operator]
  endif
  return {}
endfunction

function! nerdtreeharvest#readOperator() abort
  let l:colon = ''
  let l:helpshown = 0
  while 1
    let l:c = getchar()
    if type(l:c) == type(0)
      let l:c = nr2char(l:c)
    endif
    if l:c ==# "\<Esc>" || l:c ==# "\<C-C>"
      return ''
    elseif l:c ==# "\<CR>"
      if l:helpshown
        redraw
      endif
      return l:colon
    elseif !empty(l:colon) || l:c ==# ':'
      if l:c ==# "\<BS>" || l:c ==# "\<Del>"
        let l:colon = l:colon[:-2]
      else
        let l:colon .= l:c
      endif
    elseif l:c ==# '?'
      call nerdtreeharvest#showHelp(l:helpshown)
      let l:helpshown = 1
    else
      if l:helpshown
        redraw
      endif
      return l:c
    endif
  endwhile
endfunction

function! nerdtreeharvest#modifier(operator) abort
  let l:op = nerdtreeharvest#getOp(a:operator)
  if a:operator =~# '^:'
    " : mapping accepts an arbitrary modifier; y:h:h yanks head's head.
    return a:operator
  elseif has_key(l:op, 'modifier')
    return l:op['modifier']
  endif
  return ''
endfunction

function! nerdtreeharvest#showHelp(forceFull) abort
  let l:help = []
  for l:op in s:helporder
    call extend(l:help, [l:op, nerdtreeharvest#getOp(l:op).name])
  endfor
  let l:text = join(l:help)
  if !a:forceFull && len(l:text) >= &columns
    let l:text = join(s:helporder)
  endif
  echo l:text
endfunction

function! nerdtreeharvest#ringBell() abort
  execute "normal \<Esc>"
endfunction

scriptencoding utf-8
 
" Preserve 'cpoptions'
let s:save_cpo = &cpo
set cpo&vim


" ==============================================================================
" Util
" ==============================================================================
" ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

let s:util = {}

function! s:_export_()
  return s:
endfunction

"
" [For testing] Get SID of this file.
"
function! hlmarks#util#sid()
  return maparg('<SID>', 'n')
endfunction
nnoremap <SID>  <SID>

"
" [For testing] Get local variables in this file.
"
function! hlmarks#util#scope()
  return s:
endfunction

"
" Public.
" ______________________________________________________________________________
" ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

"
" [For debugging] Present message.
"
" Param:  [Any] message: contents
" Param:  [Number] (a:1) flag whether clear console or not
"                        (optional, default=no)
" Note:   Use VimConsole plugin if installed.
"
function! hlmarks#util#log(message, ...)
  if exists(":VimConsole")
    if a:0 && a:1
      call vimconsole#clear()
    endif
    call vimconsole#winopen()
    call vimconsole#log(a:message)
    call vimconsole#redraw()
  else
    echo string(a:message)
  endif
endfunction


" Restore 'cpoptions'
let &cpo = s:save_cpo
unlet s:save_cpo

scriptencoding utf-8
 
" Preserve 'cpoptions'
let s:save_cpo = &cpo
set cpo&vim


" ==============================================================================
" Buffer
" ==============================================================================
" ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

let s:buffer = {}

function! s:_export_()
  return s:
endfunction

"
" [For testing] Get SID of this file.
"
function! hlmarks#buffer#sid()
  return maparg('<SID>', 'n')
endfunction
nnoremap <SID>  <SID>

"
" [For testing] Get local variables in this file.
"
function! hlmarks#buffer#scope()
  return s:
endfunction

"
" Public.
" ______________________________________________________________________________
" ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

"
" Get buffer numbers.
"
" Param:  [List] list of buffer numbers
"
function! hlmarks#buffer#numbers()
  return s:extract_numbers(s:bundle())
endfunction

"
" Private.
" ______________________________________________________________________________
" ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

"
" Get strings of buffer list.
"
" Return: [String] bundle that contains buffer list
" Note:   List all buffers with '!' option.
"
function! s:bundle()
  redir => bundle
    silent execute 'ls!'
  redir END

  return bundle
endfunction

"
" Extract buffer number from bundle that is taken from 'ls!' command.
"
" Param:  [String] bundle: bundle of listed buffers
" Return: [List] list of extracted buffer number
"
function! s:extract_numbers(bundle)
  let buffer_numbers = []

  for crumb in split(a:bundle, "\n")
    let matched = matchlist(crumb, '\v^\s+(\d+)')
    if !empty(matched)
      call add(buffer_numbers, str2nr(matched[1], 10))
    endif
  endfor

  return buffer_numbers
endfunction


" Restore 'cpoptions'
let &cpo = s:save_cpo
unlet s:save_cpo

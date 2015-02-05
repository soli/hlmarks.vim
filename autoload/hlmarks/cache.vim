scriptencoding utf-8
 
" Preserve 'cpoptions'
let s:save_cpo = &cpo
set cpo&vim


" ==============================================================================
" Cache
" ==============================================================================
" ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

let s:cache = {
  \ 'name':       'hlmarks_cache',
  \ 'check_key':  '_NEVER_USED_'
  \ }

function! s:_export_()
  return s:
endfunction

"
" Public.
" ______________________________________________________________________________
" ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

"
" Clean up cache.
"
" Param:  [List] (a:1) list of buffer numbers (default=['%'])
"
function! hlmarks#cache#clean(...)
  let buffer_numbers = a:0 ? a:1 : ['%']
  for buffer_no in buffer_numbers
    let check = s:getbufvar(buffer_no, s:cache.name, s:cache.check_key)
    if !(type(check) == type(s:cache.check_key) && check == s:cache.check_key)
      call setbufvar(buffer_no, s:cache.name, {})
    endif
    unlet check
  endfor
endfunction

"
" Get from cache.
"
" Param:  [String] key: key of data in cache
" Param:  [Any] default: default value if missed cache
" Return: [Any] cached data
"
function! hlmarks#cache#get(key, default)
  let cache = s:getbufvar('%', s:cache.name, {})
  return get(cache, a:key, a:default)
endfunction

"
" Set to cache.
"
" Param:  [String] key: key of data in cache
" Param:  [Any] value: data that is stored to cache
"
function! hlmarks#cache#set(key, value)
  let cache = s:getbufvar('%', s:cache.name, {})
  let cache[a:key] = a:value
  call setbufvar('%', s:cache.name, cache)
endfunction

"
" Private.
" ______________________________________________________________________________
" ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

"
" Get buffer local variable adjusting cui.
"
" Param:  [String] expr: 1st argument for getbufvar()
" Param:  [String] varname: 2nd argument for getbufvar()
" Param:  [Any] def: 3rd argument for getbufvar()
" Return: [Any] content of designated buffer local variable
" Note:   In running cui, native getbufvar() do not accept 3rd argument. 8-(
"         See also => https://github.com/vim-jp/issues/issues/245
"
function! s:getbufvar(expr, varname, def)
  return get(getbufvar(a:expr, ''), a:varname, a:def)
endfunction


" Restore 'cpoptions'
let &cpo = s:save_cpo
unlet s:save_cpo

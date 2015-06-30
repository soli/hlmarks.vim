execute 'cd %:p:h'
execute 'source benchmark.vim'

if exists('s:target') | unlet s:target | end
let s:target = ''


function! s:test_index(...)
  return index([
    \ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
    \ 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 
    \ 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 
    \ 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 
    \ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 
    \ '.', "'", '`', '^', '<', '>', '[', ']', '{', '}', '(', ')', '"'
    \ ], 'K')
endfunction


function! s:test_stridx(...)
  return stridx('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.''`^<>[]{}()"', 'K')
endfunction


call benchmark#invoke(function('s:test_index'), s:target)
call benchmark#invoke(function('s:test_stridx'), s:target)


execute 'cd %:p:h'
execute 'source benchmark.vim'

if exists('s:target') | unlet s:target | end
let s:target = [2, 7, 8, 10, 1, 5, 3, 9, 4, 6]


function! s:sorter(a, b)
  return a:a < a:b ? -1 : (a:a > a:b ? 1 : 0)
endfunction


function! s:test_max(...)
  return max(a:1)
endfunction


" Not correct...
function! s:test_sort(...)
  return sort(a:1)[-1]
endfunction


function! s:test_sort_func(...)
  return sort(a:1, 's:sorter')[-1]
endfunction


call benchmark#invoke(function('s:test_max'), s:target)
call benchmark#invoke(function('s:test_sort'), s:target)
call benchmark#invoke(function('s:test_sort_func'), s:target)


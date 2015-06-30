execute 'cd %:p:h'
execute 'source benchmark.vim'

if exists('s:target') | unlet s:target | end
let s:target = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.''`^<>[]{}()"'
let s:last_idx = strlen(s:target) - 1


function! s:test_strpart(...)
  let idx = 0
  while idx <= a:2
    let r = strpart(a:1, idx, 1)
    let idx += 1
  endwhile
  return r
endfunction


function! s:test_range(...)
  let idx = 0
  while idx <= a:2
    let r = a:1[idx : idx]
    let idx += 1
  endwhile
  return r
endfunction


call benchmark#invoke(function('s:test_strpart'), s:target, s:last_idx)
call benchmark#invoke(function('s:test_range'), s:target, s:last_idx)


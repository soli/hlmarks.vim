execute 'cd %:p:h'
execute 'source benchmark.vim'

if exists('s:target') | unlet s:target | end
let s:target = 99


function! s:test_for(...)
  for elm in range(0, a:1)
  endfor
  return elm
endfunction


function! s:test_while(...)
  let idx = 0
  let last_idx = a:1
  while idx <= last_idx
    let idx += 1
  endwhile
  return idx - 1
endfunction


call benchmark#invoke(function('s:test_for'), s:target)
call benchmark#invoke(function('s:test_while'), s:target)


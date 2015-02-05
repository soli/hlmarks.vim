execute 'cd %:p:h'
execute 'source benchmark.vim'

function! s:parse(bundle)
  let last_idx = strlen(a:bundle) - 1
  let parsed = []
  if last_idx < 0
    return parsed
  endif
  let idx = 0
  while idx <= last_idx
    call add(parsed, strpart(a:bundle, idx, 1))
    let idx += 1
  endwhile
  return parsed
endfunction

let s:target_seq = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
let s:target_list = s:parse(s:target_seq)


function! s:test_list(...)
  for elm in a:1
    let r = elm
  endfor
  return r
endfunction


function! s:test_parse_list(...)
  for elm in s:parse(a:1)
    let r = elm
  endfor
  return r
endfunction


function! s:test_range(...)
  let idx = 0
  let last_idx = strlen(a:1) - 1
  while idx <= last_idx
    let r = a:1[idx : idx]
    let idx += 1
  endwhile
  return r
endfunction


call benchmark#invoke(function('s:test_list'), s:target_list)
call benchmark#invoke(function('s:test_parse_list'), s:target_seq)
call benchmark#invoke(function('s:test_range'), s:target_seq)


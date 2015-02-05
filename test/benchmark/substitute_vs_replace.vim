execute 'cd %:p:h'
execute 'source benchmark.vim'

let s:V = vital#of('vital')
let s:DS = s:V.import('Data.String')

if exists('s:target') | unlet s:target | end
let s:target = '=999'


function! s:test_substitute(...)
  return substitute(a:1, '=', '', '')
endfunction


function! s:test_replace(...)
  return s:DS.replace(a:1, '=', '')
endfunction


function! s:test_slice(...)
  return a:1[1:-1]
endfunction


call benchmark#invoke(function('s:test_substitute'), s:target)
call benchmark#invoke(function('s:test_replace'), s:target)
call benchmark#invoke(function('s:test_slice'), s:target)


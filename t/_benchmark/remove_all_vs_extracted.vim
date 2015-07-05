execute 'cd %:p:h'
execute 'source benchmark.vim'

if exists('s:target') | unlet s:target | end
let s:target = 99


function! s:set_mark()
  for name in ['a', 'b', 'c', 'd', 'e']
    execute 'mark '.name
  endfor
endfunction

function! s:get_bundle()
  redir => bundle
    silent! execute printf('marks %s', 'abcdef')
  redir END
  return bundle
endfunction

function! s:extract_bundle(bundle)
  let marks = {}
  for crumb in split(a:bundle, "\n")
    let matched = matchlist(crumb, '\v^\s+(\S)\s+(\d+)\s+')
    if !empty(matched)
      let marks[matched[1]] = str2nr(matched[2], 10)
    endif
  endfor
  return marks
endfunction


function! s:test_remove_by_all_deletable_chars(...)
  call s:set_mark()

  silent! delmarks abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.^<>[]\"
endfunction


function! s:test_remove_combination_commands(...)
  call s:set_mark()

  silent! delmarks!
  silent! delmarks <>\"
  silent! ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789
endfunction


function! s:test_remove_extraction(...)
  call s:set_mark()

  let marks = s:extract_bundle(s:get_bundle())
  silent! execute 'delmarks ' . join(keys(marks), '')
  return marks
endfunction


call benchmark#invoke(function('s:test_remove_by_all_deletable_chars'))
call benchmark#invoke(function('s:test_remove_combination_commands'))
call benchmark#invoke(function('s:test_remove_extraction'))


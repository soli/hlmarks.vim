execute 'cd %:p:h'
execute 'source benchmark.vim'

let s:V = vital#of('vital')
let s:DS = s:V.import('Data.String')

if exists('s:target') | unlet s:target | end
let s:target = [
  \ "\n--- サイン ---",
  \ " [NULL] のサイン:",
  \ "     行=2  識別子=52  名前=ShowMarks_a"
  \ ]


function! s:test_matchlist(...)
  let r = []
  for crumb in a:1
    let matched = matchlist(crumb, '^\s\+\S\+=\(\d\+\)\s\+\S\+=\(\d\+\)\s\+\S\+=\S\+$')
    if !empty(matched)
      call add(r, {'no': matched[1], 'id': matched[2]})
    endif
  endfor
  return r
endfunction


function! s:test_matchlist_search(...)
  let r = []
  for crumb in a:1
    if stridx(crumb, '=') >= 0
      let matched = matchlist(crumb, '^\s\+\S\+=\(\d\+\)\s\+\S\+=\(\d\+\)\s\+\S\+=\S\+$')
      if !empty(matched)
        call add(r, {'no': matched[1], 'id': matched[2]})
      endif
    endif
  endfor
  return r
endfunction


function! s:test_split(...)
  let r = []
  for crumb in a:1
    if stridx(crumb, '=') >= 0
      let splited = split(crumb, '\s\+')
      if len(splited) == 3
        " call remove(splited, -1)
        call map(splited, 'split(v:val, "=")[1]')
        call add(r, {'no': splited[0], 'id': splited[1]})
      endif
    endif
  endfor
  return r
endfunction


function! s:test_scan(...)
  let r = []
  for crumb in a:1
    if stridx(crumb, '=') >= 0
      let splited = s:DS.scan(crumb, '=\d\+')
      if len(splited) >= 2
        call add(r, {'no': (splited[0])[1:-1], 'id': (splited[1])[1:-1]})
      endif
    endif
  endfor
  return r
endfunction


call benchmark#invoke(function('s:test_matchlist'), s:target)
call benchmark#invoke(function('s:test_matchlist_search'), s:target)
call benchmark#invoke(function('s:test_split'), s:target)
call benchmark#invoke(function('s:test_scan'), s:target)


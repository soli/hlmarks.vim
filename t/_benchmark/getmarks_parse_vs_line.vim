execute 'cd %:p:h'
execute 'source benchmark.vim'

if exists('s:target') | unlet s:target | end
let s:target = ''


function! s:set_marks()
  let marks = [
    \'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
    \ 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    \ 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N',
    \ 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
    \ ]
  let lineno = 1
  for c in marks
    let cmd = string(lineno) . 'mark ' . c
    execute cmd
    let lineno += 1
  endfor
endfunction

function! s:del_marks()
  execute 'delmarks!'
  execute 'delmarks A-Z'
endfunction


function! s:test_get_by_mixcmd(...)
  redir => allmarks
    silent execute 'marks'
  redir END

  let r = {}
  for crumb in split(allmarks, "\n")
    let matched = matchlist(crumb, '^\s\+\(\S\)\s\+\(\d\+\)')
    if !empty(matched)
      let r[matched[1]] = str2nr(matched[2])
    endif
  endfor

  for crumb in ['(', ')', '{', '}']
    let linepos = line("'" . crumb)
    if linepos != 0
      let r[crumb] = linepos
    endif
  endfor

  return r
endfunction


function! s:test_get_by_linecmd(...)
  redir => allmarks
    silent execute 'marks'
  redir END

  let splited = split(allmarks, "\n") + [
    \ ' (',
    \ ' )',
    \ ' {',
    \ ' }'
    \ ]

  let r = {}
  for crumb in splited
    let matched = matchlist(crumb, '^\s\+\(\S\)')
    if !empty(matched)
      let linepos = line("'" . matched[1])
      if linepos != 0
        let r[matched[1]] = linepos
      endif
    endif
  endfor
  return r
endfunction


call s:set_marks()
call benchmark#invoke(function('s:test_get_by_mixcmd'), s:target)
call benchmark#invoke(function('s:test_get_by_linecmd'), s:target)
call s:del_marks()


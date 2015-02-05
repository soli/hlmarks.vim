execute 'cd %:p:h'
execute 'source benchmark.vim'

if exists('s:target') | unlet s:target | end
let s:target = ''


function! s:marks(scale)
  let less_marks = [
    \'a', 'b', 'c', 'd', 'e', 'f', 'g'
    \ ]
  let much_marks = [
    \'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
    \ 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
    \ 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N',
    \ 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'
    \ ]
  return {a:scale}_marks
endfunction

function! s:set_marks(scale)
  let lineno = 1
  for c in s:marks(a:scale)
    let cmd = string(lineno) . 'mark ' . c
    execute cmd
    let lineno += 1
  endfor
endfunction

function! s:del_marks()
  execute 'delmarks!'
  execute 'delmarks A-Z'
endfunction


function! s:test_filtered(...)
  redir => bundle
    silent execute 'marks'
  redir END

  let r = {}
  for crumb in split(bundle, "\n") + [' (', ' )', ' {', ' }']
    let matched = matchlist(crumb, '^\s\+\(\S\)')
    if !empty(matched) && (stridx(a:1, matched[1]) >= 0)
      let linepos = line("'" . matched[1])
      if linepos != 0
        let r[matched[1]] = linepos
      endif
    endif
  endfor
  return r
endfunction


function! s:test_line(...)
  let r = {}
  let idx = 0
  let last_idx = strlen(a:1) - 1
  while idx <= last_idx
    let mark_name = a:1[idx : idx]
    let linepos = line("'" . mark_name)
    if linepos != 0
      let r[mark_name] = linepos
    endif
    let idx += 1
  endwhile
  return r
endfunction


" less marks, actually
call s:set_marks('less')
call benchmark#invoke(function('s:test_filtered'), join(s:marks('much'), ''))
call benchmark#invoke(function('s:test_line'), join(s:marks('much'), ''))
call s:del_marks()

" much
call s:set_marks('much')
call benchmark#invoke(function('s:test_filtered'), join(s:marks('much'), ''))
call benchmark#invoke(function('s:test_line'), join(s:marks('much'), ''))
call s:del_marks()


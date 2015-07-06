"
" Check mark existence.
"
function! Expect_Mark(marks, should_present)
  let bundle = _Grab_('marks')
  for name in a:marks
    if a:should_present
      let matched = []
      for crumb in bundle
        if crumb =~# '\v^\s+'.escape(name, '.^[]<>{}()').'\s+\d'
          call add(matched, name)
          break
        endif
      endfor
      " Inspector
      if matched == []
        Expect name == '(debug)'
      endif
      Expect len(matched) == 1
    else
      for crumb in bundle
        Expect crumb !~# '\v^\s+'.escape(name, '.^[]{}()').'\s+\d'
      endfor
    endif
  endfor
endfunction

"
" Check sign exsitence.
"
function! Expect_Sign(signs, line_no, should_present)
  let bundle = _Grab_('sign place buffer=' . bufnr('%'))
  for name in a:signs
    if a:should_present
      let matched = []
      for crumb in bundle
        if crumb =~# '\vline\='.a:line_no.'.+name\='.name
          call add(matched, name)
        endif
      endfor
      " Inspector
      if empty(matched)
        Expect name == '(debug)'
      endif
      Expect len(matched) == 1
    else
      for crumb in bundle
        Expect crumb !~# '\vline\='.a:line_no.'.+name\='.name
      endfor
    endif
  endfor
endfunction


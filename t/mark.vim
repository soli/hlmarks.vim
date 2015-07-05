execute 'source ' . expand('%:p:h') . '/t/_common/test_helpers.vim'

runtime! plugin/hlmarks.vim

call vspec#hint({'scope': 'hlmarks#mark#scope()', 'sid': 'hlmarks#mark#sid()'})



function! s:Reg(subject)
  return _Reg_('__t__', a:subject)
endfunction


function! s:StashGlobal(subject)
  let subject = a:subject != 0 ? 'hlmarks_' : 0
  call _Stash_(subject)
endfunction


function! s:Local(subject)
  return _HandleLocalDict_('s:mark', a:subject)
endfunction


function! s:prepare_mark(...)
  let param = a:0 ? a:1 : {'c': ['a', 'A'], 'o': ['b', 'B']}
  let fix_lno = a:0 == 2 ? 1 : 0

  if type(param) == type(1) && param == 0
    let mark_str = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.^<>[]"'
    execute 'delmarks '.mark_str
    quit!
    execute 'delmarks '.mark_str
    return {}
  endif

  " Origin buffer number always becomes '2' if add one buffer. DO NOT use winnr(|#|$) 
  let other_wno = 2
  let other_bno = bufnr('%')
  let other_spec = {}
  let line_no = 1
  for name in param['o']
    put =['']
    call cursor(line_no, 1)
    execute 'normal m'.name
    let other_spec[name] = line_no
    if !fix_lno
      let line_no += 1
    endif
  endfor

  new

  " Newly buffer number always becomes '1' if add one buffer. DO NOT use winnr(|#|$) 
  let current_wno = 1
  let current_bno = bufnr('%')
  let current_spec = {}
  let line_no = 1
  for name in param['c']
    put =['']
    call cursor(line_no, 1)
    execute 'normal m'.name
    let current_spec[name] = line_no
    if !fix_lno
      let line_no += 1
    endif
  endfor

  let merged = deepcopy(current_spec, 1)
  call extend(merged, deepcopy(other_spec, 1))

  let globals = {}
  for [name, line_no] in items(current_spec)
    if name =~ '\v^\u|\d$'
      let globals[name] = line_no
    endif
  endfor
  for [name, line_no] in items(other_spec)
    if name =~ '\v^\u|\d$'
      let globals[name] = line_no
    endif
  endfor

  return {
    \ 'c': current_spec,
    \ 'o': other_spec,
    \ 'a': merged,
    \ 'g': globals,
    \ 'w': {'c': current_wno, 'o': other_wno},
    \ 'b': {'c': current_bno, 'o': other_bno},
    \ }
endfunction


function! s:expect_presence(marks, should_present)
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



describe 'specs_for_sign()'

  it 'should return local/global mark specs only in current buffer'
    let signable_marks = split(g:hlmarks_displaying_marks, '\zs')
    let mark_data = s:prepare_mark({'c': signable_marks, 'o': []})
    let mark_spec = mark_data.c

    let result = hlmarks#mark#specs_for_sign()

    Expect len(mark_spec) == len(signable_marks)
    Expect len(result) == len(mark_spec)

    for [name, line_no] in items(result)
      Expect index(signable_marks, name) >= 0
      Expect has_key(mark_spec, name) to_be_true
      Expect line_no == mark_spec[name]
    endfor

    call s:prepare_mark(0)

  end

  it 'should return empty dict if no mark is placed'
    Expect hlmarks#mark#specs_for_sign() == {}
  end

end


describe 'generate_name()'

  before
    call s:Local(1)
  end

  after
    call s:Local(0)
  end

  it 'should return next character that is not used yet'
    let marks = {'c': ['a', 'b'], 'o': []}
    let mark_data = s:prepare_mark(marks)

    Expect hlmarks#mark#generate_name() == 'c'

    call s:prepare_mark(0)
  end

  it 'should not return alphabetical global marks(A-Z)'
    let automark_candidate = s:Local('automarkables')

    Expect automark_candidate =~# '\v^[a-z]+$'
  end

  it 'should return empty string if all marks are used'
    let marks = {'c': ['a', 'b'], 'o': []}
    let mark_data = s:prepare_mark(marks)

    call s:Local({'automarkables': 'ab'})

    Expect hlmarks#mark#generate_name() == ''

    call s:prepare_mark(0)
  end

end


describe 'generate_state()'

  it 'should generate current mark state'
    let mark_data = s:prepare_mark()
    let mark_spec = mark_data.c

    let state = hlmarks#mark#generate_state()

    Expect len(state) == len(mark_spec)

    for [name, line_no] in items(state)
      Expect has_key(mark_spec, name) to_be_true
      Expect mark_spec[name] == line_no
    endfor

    call s:prepare_mark(0)
  end

end


describe 'get_cache()'

  it 'should return empty hash if cache is empty'
    let cache = hlmarks#mark#get_cache()

    Expect cache == {}
  end

  it 'should return cache that is set by set_cache()'
    let mark_data = s:prepare_mark()
    let mark_spec = mark_data.c

    call hlmarks#mark#set_cache()

    let cache = hlmarks#mark#get_cache()

    Expect len(cache) == len(mark_spec)

    for [name, line_no] in items(cache)
      Expect has_key(mark_spec, name) to_be_true
      Expect mark_spec[name] == line_no
    endfor

    call s:prepare_mark(0)
  end

end


describe 'should_handle()'

  before
    call s:Local(1)
    call s:Local({'togglables': 'abc'})
  end

  after
    call s:Local(0)
  end

  it 'should return true passed mark has correct length and is in predefined list'
    Expect hlmarks#mark#should_handle('a') to_be_true
  end

  it 'should return false passed mark has 2 or more length or is not in list'
    Expect hlmarks#mark#should_handle('d') to_be_false
    Expect hlmarks#mark#should_handle('aa') to_be_false
  end

end


describe 'pos()'

  it 'should return line/buffer number for normally marks'
    let marks = split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ<>', '\zs')
    let mark_data = s:prepare_mark({'c': marks, 'o': []})
    let buffer_no = bufnr('%')

    for [name, line_no] in items(mark_data.c)
      Expect hlmarks#mark#pos(name) == [buffer_no, line_no]
    endfor

    call s:prepare_mark(0)
  end

  it 'should return line/buffer number for auto-generating marks'
    " Create mark .^ (As below expresion, double quote is required for backslash and output escape.
    execute "normal Inew text \<Esc>"

    let buffer_no = bufnr('%')
    for name in ['.', '^']
      let pos = hlmarks#mark#pos(name)
      Expect pos[0] == buffer_no
      Expect string(pos[1]) =~ '\v^\d+$'
    endfor
  end

  it 'should return line/buffer number for dynamic marks'
    let dynamics = ["'", '`', '[', ']', '"']

    for name in dynamics
      let mark_data = s:prepare_mark({'c': [name], 'o': []})
      let buffer_no = bufnr('%')

      Expect hlmarks#mark#pos(name) == [buffer_no, mark_data.c[name]]

      call s:prepare_mark(0)
    endfor
  end

  it 'should return line/buffer number for invisible marks'
    let invisibles = ['(', ')', '{', '}']

    " Set some dummy marks.
    let mark_data = s:prepare_mark({'c': ['a', 'b', 'c'], 'o': []})
    " Single/back/double-quote is set in this point.
    " Create mark .^ (As below expresion, double quote is required for backslash and output escape.
    execute "normal Inew text \<Esc>"

    let buffer_no = bufnr('%')
    for name in invisibles
      let pos = hlmarks#mark#pos(name)
      Expect pos[0] == buffer_no
      Expect string(pos[1]) =~ '\v^\d+$'
    endfor
  end

end


describe 'remove()'

  it 'should try to remove passed any mark with suppressing errors'
    " Marks - can be set manually, deletable/undeletable, static/dynamic position.
    let enable_set_manually = split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ`''<>[]', '\zs')
    let enable_remove = split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.^<>[]"', '\zs')
    let unable_remove = '`''(){}' " '`' is appears as `'` in marks command result.

    let mark_data = s:prepare_mark({'c': enable_set_manually, 'o': []})
    " Single/back/double-quote is set in this point.
    " Create mark .^ (As below expresion, double quote is required for backslash and output escape.
    execute "normal Inew text \<Esc>"

    call hlmarks#mark#remove(join(enable_remove, ''))
    call hlmarks#mark#remove(unable_remove)

    call s:expect_presence(enable_remove, 0)

    call s:prepare_mark(0)
  end

end


describe 'remove_all()'

  it 'should remove all marks in current buffer'
    " Marks - can be set manually, deletable, static/dynamic position.
    let marks_current = split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMN<>[]', '\zs')
    " Marks - can be set manually, deletable/undeletable, static/dynamic position.(except '`')
    let marks_other = split('abcdefghijklmnopqrstuvwxyzOPQRSTUVWXYZ''<>[]', '\zs')
    " Marks - deletable, except some globals that are placed in other buffer.
    let should_be_removed = split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMN0123456789.^<>[]"', '\zs')

    " Set marks that can be set manually.
    let mark_data = s:prepare_mark({'c': marks_current, 'o': marks_other})
    " Single/back/double-quote is set in this point.
    " Create mark .^ (As below expresion, double quote is required for backslash and output escape.
    execute "normal Inew text \<Esc>"

    call hlmarks#mark#remove_all()

    call s:expect_presence(should_be_removed, 0)

    execute mark_data.w.o . 'wincmd w'
    call s:expect_presence(marks_other, 1)
    execute mark_data.w.c . 'wincmd w'

    call s:prepare_mark(0)
  end

end


describe 'remove_on_line()'

  it 'should remove mark that is placed on designated line only current buffer and return it as list'
    " Marks - can be set manually, deletable, static position.
    let marks_current_1 = split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMN<>', '\zs')
    " Marks - can be set manually, deletable, dynamic position.
    let marks_current_2 = split('[]', '\zs')
    " Marks - can be set manually, deletable/undeletable, static/dynamic position.(except '`')
    let marks_other = split('abcdefghijklmnopqrstuvwxyzOPQRSTUVWXYZ''<>[]', '\zs')

    " Set marks that can be set manually.
    let mark_data = s:prepare_mark({'c': marks_current_1, 'o': marks_other})
    " Single/back/double-quote is set in this point.
    " Create mark .^ (As below expresion, double quote is required for backslash and output escape.
    execute "normal Inew text \<Esc>"

    let mark_spec = mark_data.c

    for [name, line_no] in items(mark_spec)
      let result = hlmarks#mark#remove_on_line(line_no)
      " Inspector
      if result == []
        Expect name.'='.line_no.':'.(string(getpos("'".name))) == '(debug)'
      endif
      " Dynamic marks are removed together some static marks, so check by existence.
      Expect index(result, name) >= 0
      call s:expect_presence([name], 0)
    endfor

    " Remove marks that can not be set but deletable(but perhaps, .^ are removed in this point).
    for line_no in range(1, line('$'))
      call hlmarks#mark#remove_on_line(line_no)
    endfor

    call s:expect_presence(['.', '^', '"'], 0)

    execute mark_data.w.o . 'wincmd w'
    call s:expect_presence(marks_other, 1)
    execute mark_data.w.c . 'wincmd w'

    call s:prepare_mark(0)

    " Dynamic marks.
    for name in marks_current_2
      let mark_data = s:prepare_mark({'c': [name], 'o': []})
      Expect index(hlmarks#mark#remove_on_line(mark_data.c[name]), name) >= 0
      call s:prepare_mark(0)
    endfor
  end

  it 'should remove all marks on same line'
    let marks = ['a', 'b']
    let mark_data = s:prepare_mark({'c': marks, 'o': []}, 1)
    let line_no = mark_data.c[marks[0]]

    let result = hlmarks#mark#remove_on_line(line_no)

    for name in marks
      Expect index(result, name) >= 0
    endfor

    call s:prepare_mark(0)
  end

end


describe 'set()'

  it 'should set mark that can be placed manually'
    " Marks - can be set manually, deletable/undeletable, static/dynamic position.(except '`')
    let enable_set_manually = split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ''<>[]', '\zs')

    " Must be manually in test.
    silent! execute printf('noremap <script><unique> %s m', g:hlmarks_alias_native_mark_cmd)

    for name in enable_set_manually
      call hlmarks#mark#set(name)
    endfor

    call s:expect_presence(enable_set_manually, 1)

    " Revert map.
    silent! execute printf('unmap %s', g:hlmarks_alias_native_mark_cmd)
  end

end


describe 's:bundle()'

  before
    call s:Reg({
      \ 'func': 's:bundle',
      \ })
  end

  after
    call s:Reg(0)
  end

  it 'should return info for designated mark in current buffer(but globals in others) as single strings crumb'
    " c(a A), o(b B) =(all)=> a, A, B
    let mark_data = s:prepare_mark()

    let bundle = Call(s:Reg('func'), join(keys(mark_data.a), ''))

    for [name, line_no] in items(mark_data.c)
      Expect bundle =~# '\v'.name.'\s+'.line_no.'\D+'
    endfor

    for [name, line_no] in items(mark_data.g)
      Expect bundle =~# '\v'.name.'\s+'.line_no.'\D+'
    endfor

    call s:prepare_mark(0)
  end

  it 'should return info for invisible marks that normally can not get by command'
    let mark_data = s:prepare_mark()
    let invisibles = ['(', ')', '{', '}']

    let bundle = Call(s:Reg('func'), join(invisibles, ''))

    Expect bundle !~? 'error'

    for name in keys(mark_data.a)
      Expect bundle !~# '\v'.name.'\s+'
    endfor

    for name in invisibles
      Expect bundle =~# '\v'.escape(name, join(invisibles, '')).'\s+\d{1,}.{-1,}\(invisible\)'
    endfor

    call s:prepare_mark(0)
  end

  it 'should return correct info if mixed(normal and invisible) marks are designated'
    let mark_data = s:prepare_mark()
    let invisibles = ['(', ')', '{', '}']

    let bundle = Call(s:Reg('func'), join((keys(mark_data.c) + invisibles), ''))

    Expect bundle !~? 'error'

    for [name, line_no] in items(mark_data.c)
      Expect bundle =~# '\v'.name.'\s+'.line_no.'\D+'
    endfor

    for name in invisibles
      Expect bundle =~# '\v'.escape(name, join(invisibles, '')).'\s+\d{1,}.{-1,}\(invisible\)'
    endfor

    call s:prepare_mark(0)
  end

  it 'should return info for all available marks'
    " All marks except below marks.
    "   - Global 0-9 because there marks can not be set here.
    "   - Back-quote(`) is apprears in list as single(').
    let all_marks = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.''^<>[]{}()"'
    let enable_set_manually = split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ''`<>[]', '\zs')

    " Set marks that can be set manually.
    let mark_data = s:prepare_mark({'c': enable_set_manually, 'o': []})
    " Single/back/double-quote is set in this point.
    " Create mark .^ (As below expresion, double quote is required for backslash and output escape.
    execute "normal Inew text \<Esc>"

    let bundle = Call(s:Reg('func'), all_marks)

    for name in split(all_marks, '\zs')
      Expect bundle =~# '\v\s+'.escape(name, '.^[]<>{}()').'\s+\d'
    endfor
  end

end


describe 's:extract()'

  before
    call s:Reg({
      \ 'func': 's:extract',
      \ 'bundle_func': 's:bundle',
      \ })
  end

  after
    call s:Reg(0)
  end

  it 'should extract all marks info from single strings crumb'
    " All marks except below marks.
    "   - Global 0-9 because there marks can not be set here.
    "   - Back-quote(`) is apprears in list as single(').
    let all_marks = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.''^<>[]{}()"'
    " Marks - can be set manually, deletable/undeletable, static/dynamic position.(except '`')
    let marks_current = split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMN''<>[]', '\zs')
    let marks_other = split('abcdefghijklmnopqrstuvwxyzOPQRSTUVWXYZ''<>[]', '\zs')

    let mark_data = s:prepare_mark({'c': marks_current, 'o': marks_other})
    " Single/back/double-quote is set in this point.
    " Create mark .^ (As below expresion, double quote is required for backslash and output escape.
    execute "normal Inew text \<Esc>"

    let mark_spec = mark_data.c
    let bundle = Call(s:Reg('bundle_func'), all_marks)

    let result = Call(s:Reg('func'), bundle, 1)

    Expect len(result) == len(split(all_marks, '\zs'))

    for [name, line_no] in items(result)
      " Except dynamics.
      if has_key(mark_spec, name) && index(['[', ']'], name) < 0
        Expect line_no == mark_spec[name]
      endif
    endfor

    call s:prepare_mark(0)
  end

  it 'should extract all marks info except global in other buffer'
    " All marks except below marks.
    "   - Global 0-9 because there marks can not be set here.
    "   - Back-quote(`) is apprears in list as single(').
    let all_marks = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.''^<>[]{}()"'
    let all_marks_current = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMN.''^<>[]{}()"'
    " Marks - can be set manually, deletable/undeletable, static/dynamic position.(except '`')
    let marks_current = split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMN''<>[]', '\zs')
    let marks_other = split('abcdefghijklmnopqrstuvwxyzOPQRSTUVWXYZ''<>[]', '\zs')

    let mark_data = s:prepare_mark({'c': marks_current, 'o': marks_other})
    " Single/back/double-quote is set in this point.
    " Create mark .^ (As below expresion, double quote is required for backslash and output escape.
    execute "normal Inew text \<Esc>"

    let mark_spec = mark_data.c
    let bundle = Call(s:Reg('bundle_func'), all_marks)

    let result = Call(s:Reg('func'), bundle, 0)

    Expect len(result) == len(split(all_marks_current, '\zs'))

    for [name, line_no] in items(result)
      " Except dynamics.
      if has_key(mark_spec, name) && index(['[', ']'], name) < 0
        Expect line_no == mark_spec[name]
      endif
    endfor

    call s:prepare_mark(0)
  end

  it 'should return empty dict if has no mark'
    let bundle = Call(s:Reg('bundle_func'), 'abcABC')

    let result = Call(s:Reg('func'), bundle, 1)

    Expect result == {}
  end

end


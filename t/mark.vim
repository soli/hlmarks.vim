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
    let line_no += 1
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
    let line_no += 1
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



describe 'can_remove()'

  before
    call s:Local(1)
  end

  after
    call s:Local(0)
  end

  it 'should return true if designated mark is not in list of unable-remove-marks'
    Expect hlmarks#mark#can_remove('a') to_be_true
  end

  it 'should return false if designated mark is in list of unable-remove-marks'
    Expect hlmarks#mark#can_remove("'") to_be_false

    call s:Local({'unable_remove': s:Local('unable_remove').'a'})
    Expect hlmarks#mark#can_remove('a') to_be_false
  end

end


describe 'covered()'

  it 'should return local/global mark specs only in current buffer'
    let mark_data = s:prepare_mark()
    let mark_spec = mark_data.c

    let result = hlmarks#mark#covered()

    Expect len(result) == len(mark_spec)

    for [name, line_no] in items(result)
      Expect has_key(mark_spec, name) to_be_true
      Expect line_no == mark_spec[name]
    endfor

    call s:prepare_mark(0)
  end

  it 'should return empty dict if no mark is placed'
    Expect hlmarks#mark#covered() == {}
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
    let automark_candidate = s:Local('enable_automark')

    Expect automark_candidate !~# '\v[A-Z0-9]'
  end

  it 'should return empty string if all marks are used'
    let marks = {'c': ['a', 'b'], 'o': []}
    let mark_data = s:prepare_mark(marks)

    call s:Local({'enable_automark': 'ab'})

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


describe 'is_valid()'

  before
    call s:Local(1)
    call s:Local({'enable_set_manually': 'abc'})
  end

  after
    call s:Local(0)
  end

  it 'should return true passed mark has correct length and is in predefined list'
    Expect hlmarks#mark#is_valid('a') to_be_true
  end

  it 'should return false passed mark has 2 or more length or is not in list'
    Expect hlmarks#mark#is_valid('d') to_be_false
    Expect hlmarks#mark#is_valid('aa') to_be_false
  end

end


describe 'pos()'

  it 'should return line/buffer number of passed mark'
    let marks = split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ''<>', '\zs')
    let mark_data = s:prepare_mark({'c': marks, 'o': []})
    let buffer_no = bufnr('%')

    for [name, line_no] in items(mark_data.c)
      Expect hlmarks#mark#pos(name) == [buffer_no, line_no]
    endfor

    call s:prepare_mark(0)

    " Special marks that needed single test because there spec will be changed
    " by editing or another operations.
    let marks = ['`', '[', ']']
    for name in marks
      let mark_data = s:prepare_mark({'c': [name], 'o': []})
      let buffer_no = bufnr('%')

      Expect hlmarks#mark#pos(name) == [buffer_no, mark_data.c[name]]

      call s:prepare_mark(0)
    endfor
  end

end


describe 'remove()'

  it 'should try to remove passed any mark with suppressing errors'
    let enable_set_manually = split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0`''<>[]', '\zs')
    let enable_remove = split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.^<>[]', '\zs')
    let enable_remove_with_escape = ['"']
    let unable_remove = '`''(){}' " '`' is appears as `'` in marks command result.

    let mark_data = s:prepare_mark({'c': enable_set_manually, 'o': []})

    " Create mark .^ (As below expresion, double quote is required for backslash and output escape.
    execute "normal Inew text \<Esc>"

    call hlmarks#mark#remove(join(enable_remove, ''))
    call hlmarks#mark#remove(join(enable_remove_with_escape, ''))
    call hlmarks#mark#remove(unable_remove)

    call s:expect_presence(enable_remove + enable_remove_with_escape, 0)

    call s:prepare_mark(0)
  end

end


describe 'remove_all()'

  it 'should remove all marks in current buffer'
    " Test only deletable AND manually unable to set marks.
    let marks_on_current = split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMN<>[]', '\zs')
    let marks_on_other = split('abcdefghijklmnopqrstuvwxyzOPQRSTUVWXYZ<>[]', '\zs')
    let mark_data = s:prepare_mark({'c': marks_on_current, 'o': marks_on_other})

    call hlmarks#mark#remove_all()

    call s:expect_presence(marks_on_current, 0)

    execute mark_data.w.o . 'wincmd w'
    call s:expect_presence(marks_on_other, 1)
    execute mark_data.w.c . 'wincmd w'

    call s:prepare_mark(0)
  end

end


describe 's:bundle()'

  before
    call s:Reg({
      \ 'func': 's:bundle',
      \ })

    new
  end

  after
    close!

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

  it 'should extract all mark info from single strings crumb'
    let mark_data = s:prepare_mark()
    let mark_spec = deepcopy(mark_data.c, 1)
    call extend(mark_spec, mark_data.g)
    let bundle = Call(s:Reg('bundle_func'), join(keys(mark_data.a), ''))

    let result = Call(s:Reg('func'), bundle)

    Expect len(result) == len(mark_spec)

    for [name, line_no] in items(result)
      Expect has_key(mark_spec, name) to_be_true
      Expect line_no == mark_spec[name]
    endfor

    call s:prepare_mark(0)
  end

  it 'should extract all mark info except global in other buffer'
    let mark_data = s:prepare_mark()
    let current_spec = mark_data.c
    let bundle = Call(s:Reg('bundle_func'), join(keys(mark_data.a), ''))

    let result = Call(s:Reg('func'), bundle, bufnr('%'))

    Expect len(result) == len(current_spec)

    for [name, line_no] in items(result)
      Expect has_key(current_spec, name) to_be_true
      Expect line_no == current_spec[name]
    endfor

    call s:prepare_mark(0)
  end

  it 'should return empty dict if has no mark'
    let bundle = Call(s:Reg('bundle_func'), 'abcABC')

    let result = Call(s:Reg('func'), bundle)

    Expect result == {}
  end

end


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
    close!
    execute 'delmarks '.mark_str
    return {}
  endif

  let other_spec = {}
  let line_no = 1
  for name in param['o']
    call cursor(line_no, 1)
    execute 'normal m'.name
    let other_spec[name] = line_no
    put =['']
    let line_no += 1
  endfor

  new

  let current_spec = {}
  let line_no = 1
  for name in param['c']
    call cursor(line_no, 1)
    execute 'normal m'.name
    let current_spec[name] = line_no
    put =['']
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
    \ }
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


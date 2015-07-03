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


function! s:prepare_mark(mode, ...)
  let mark_list = a:0 ? a:1 : {'c': ['a', 'A'], 'o': ['b', 'B']}

  if type(a:mode) == type(1) && a:mode == 0
    let mark_str = join(mark_list['c'], '') . join(mark_list['o'], '')
    execute 'delmarks '.mark_str
    close!
    execute 'delmarks '.mark_str
    return {}
  endif

  let other_bno = bufnr('%')
  let other_spec = {}
  let line_no = 1
  for name in mark_list['o']
    call cursor(line_no, 1)
    execute 'normal m'.name
    let other_spec[name] = line_no
    put =['']
    let line_no += 1
  endfor

  new

  let current_bno = bufnr('%')
  let current_spec = {}
  let line_no = 1
  for name in mark_list['c']
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
    \ 'c': {'no': current_bno, 'spec': current_spec},
    \ 'o': {'no': other_bno, 'spec': other_spec},
    \ 'a': merged,
    \ 'g': globals,
    \ }
endfunction



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
    let mark_data = s:prepare_mark(1)

    let bundle = Call(s:Reg('func'), join(keys(mark_data.a), ''))

    for [name, line_no] in items(mark_data.c.spec)
      Expect bundle =~# '\v'.name.'\s+'.line_no.'\D+'
    endfor

    for [name, line_no] in items(mark_data.g)
      Expect bundle =~# '\v'.name.'\s+'.line_no.'\D+'
    endfor

    call s:prepare_mark(0)
  end

  it 'should return info for invisible marks that normally can not get by command'
    let mark_data = s:prepare_mark(1)
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
    let mark_data = s:prepare_mark(1)
    let invisibles = ['(', ')', '{', '}']

    let bundle = Call(s:Reg('func'), join((keys(mark_data.c.spec) + invisibles), ''))

    Expect bundle !~? 'error'

    for [name, line_no] in items(mark_data.c.spec)
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
    let mark_data = s:prepare_mark(1)
    let mark_spec = deepcopy(mark_data.c.spec, 1)
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
    let mark_data = s:prepare_mark(1)
    let current_spec = mark_data.c.spec
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


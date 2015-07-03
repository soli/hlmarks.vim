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
  call _HandleLocalDict_('s:mark', a:subject)
endfunction


function! s:place_mark(...)
  let param = a:0 ? a:1 : ['a', 'b', 'c']

  if type(param) == type(1) && param == 0
    delmarks!
    return []
  endif

  call cursor(1, 1)
  for name in param
    execute 'normal m'.name
  endfor

  return param
endfunction


function! s:prepare_mark(mode, ...)
  let mark_list = a:0 ? a:1 : {'c': ['a', 'b', 'C'], 'o': ['A', 'B']}

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

  return {
    \ 'c': {'no': current_bno, 'spec': current_spec},
    \ 'o': {'no': other_bno, 'spec': other_spec},
    \ 'a': merged,
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

  it 'should return info for designated mark as single strings crumb'
    let mark_names = s:place_mark()
    let bundle = Call(s:Reg('func'), join(mark_names, ''))

    Expect type(bundle) == type('')

    for name in mark_names
      Expect bundle =~# '\v'.name.'\s+1'
    endfor

    call s:place_mark(0)
  end

  it 'should return info for invisible marks that normally can not get by command'
    let mark_names = s:place_mark()
    let invisibles = ['(', ')', '{', '}']
    let bundle = Call(s:Reg('func'), join(invisibles, ''))

    Expect type(bundle) == type('')
    Expect bundle !~? 'error'

    for name in mark_names
      Expect bundle !~# '\v'.name.'\s+1'
    endfor

    for name in invisibles
      Expect bundle =~# '\v'.escape(name, join(invisibles, '')).'\s+1.{-1,}\(invisible\)'
    endfor

    call s:place_mark(0)
  end

  it 'should return correct info if mixed(normal and invisible) marks are designated'
    let mark_names = s:place_mark()
    let invisibles = ['(', ')', '{', '}']
    let bundle = Call(s:Reg('func'), join((mark_names + invisibles), ''))

    Expect type(bundle) == type('')
    Expect bundle !~? 'error'

    for name in mark_names
      Expect bundle =~# '\v'.name.'\s+1'
    endfor

    for name in invisibles
      Expect bundle =~# '\v'.escape(name, join(invisibles, '')).'\s+1.{-1,}\(invisible\)'
    endfor

    call s:place_mark(0)
  end

end


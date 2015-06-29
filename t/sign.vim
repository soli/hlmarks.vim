execute 'source ' . expand('%:p:h') . '/t/_common/helpers.vim'

runtime! plugin/hlmarks.vim

call vspec#hint({'scope': 'hlmarks#sign#scope()', 'sid': 'hlmarks#sign#sid()'})


function! s:toggle_sign_defs(define)
  let sign_names = []
  for name in ['foo', 'bar', 'baz']
    let sign_name = '__test__'.name
    execute 'sign '.(a:define ? '' : 'un').'define '.sign_name
    call add(sign_names, sign_name)
  endfor

  return sign_names
endfunction


function! s:toggle_sign_placement(sign_names)
  if a:sign_names == []
    sign unplace *
    return []
  endif

  let sign_ids = []
  let id = 1
  for sign_name in a:sign_names
    execute printf('sign place %s line=%s name=%s buffer=%s', id, 1, sign_name, bufnr('%'))
    call add(sign_ids, id)
    let id += 1
  endfor

  return sign_ids
endfunction


describe 's:fix_format()'

  before
    let g:__func__ = 's:fix_format'
    let g:__ms__ = '%m'
  end

  after
    unlet g:__func__
    unlet g:__ms__
  end

  it 'should return defualt format if passed empty'
    Expect Call(g:__func__, '', g:__ms__) ==# g:__ms__
  end

  it 'should append mark specifier in front if specifier not exits and truncate if needed'
    Expect Call(g:__func__, '>', g:__ms__) ==# g:__ms__.'>'
    Expect Call(g:__func__, '>=', g:__ms__) ==# g:__ms__.'>'
  end

  it 'should pass through if passed correct valaue'
    Expect Call(g:__func__, g:__ms__, g:__ms__) ==# g:__ms__
    Expect Call(g:__func__, g:__ms__.'>', g:__ms__) ==# g:__ms__.'>'
    Expect Call(g:__func__, '>'.g:__ms__, g:__ms__) ==# '>'.g:__ms__
  end

  it 'should truncate from end if passed exceeded value'
    Expect Call(g:__func__, g:__ms__.'>X', g:__ms__) ==# g:__ms__.'>'
    Expect Call(g:__func__, '>X'.g:__ms__, g:__ms__) ==# '>'.g:__ms__
    Expect Call(g:__func__, '>'.g:__ms__.'X', g:__ms__) ==# '>'.g:__ms__
  end

  it 'should compact mark specifier if passed two or more mark specifier'
    Expect Call(g:__func__, g:__ms__.g:__ms__, g:__ms__) ==# g:__ms__
    Expect Call(g:__func__, g:__ms__.g:__ms__.'>', g:__ms__) ==# g:__ms__.'>'
    Expect Call(g:__func__, '>'.g:__ms__.g:__ms__, g:__ms__) ==# '>'.g:__ms__
    Expect Call(g:__func__, g:__ms__.'>'.g:__ms__, g:__ms__) ==# g:__ms__.'>'
    Expect Call(g:__func__, '>'.g:__ms__.'X'.g:__ms__, g:__ms__) ==# '>'.g:__ms__
    Expect Call(g:__func__, g:__ms__.'>'.g:__ms__.'X', g:__ms__) ==# g:__ms__.'>'
  end

end


describe 's:sign_names_sorter()'

  it 'should sort according to list of character order'
    SKIP 'Currently unable to test.'
  end

end


describe 's:defined_bundle()'

  before
    let g:__signs__ = s:toggle_sign_defs(1)
  end

  after
    call s:toggle_sign_defs(0)

    unlet g:__signs__
  end

  it 'should return currently defined signs as single string crumb'
    let bundle = Call('s:defined_bundle')

    Expect type(bundle) == type('') 
    Expect bundle != '' 
    Expect bundle =~# g:__signs__[0]
  end

end


describe 's:extract_chars()'

  before
    let g:__func__ = 's:extract_chars'
  end

  after
    unlet g:__func__
  end

  it 'should extract designated character class from passed strings'
    let target = 'ABCdef123<>.[]'

    Expect Call(g:__func__, 'lower', target) == 'def'
    Expect Call(g:__func__, 'upper', target) == 'ABC'
    Expect Call(g:__func__, 'number', target) == '123'
    Expect Call(g:__func__, 'symbol', target) == '<>.[]'
  end

  it 'should extract no character from empty string'
    let target = ''

    Expect Call(g:__func__, 'lower', target) == ''
    Expect Call(g:__func__, 'upper', target) == ''
    Expect Call(g:__func__, 'number', target) == ''
    Expect Call(g:__func__, 'symbol', target) == ''
  end

end


describe 's:extract_defined_names()'

  before
    let g:__func__ = 's:extract_defined_names'
    let g:__bundle_func__ = 's:defined_bundle'
    let g:__signs__ = s:toggle_sign_defs(1)
  end

  after
    call s:toggle_sign_defs(0)

    unlet g:__func__
    unlet g:__bundle_func__
    unlet g:__signs__
  end

  it 'should extarct sign names from strings by s:defined_bundle()'
    let bundle = Call(g:__bundle_func__)
    let names = Call(g:__func__, bundle, g:__signs__[0])

    Expect type(names) == type([])
    Expect len(names) == 1
    Expect names == [g:__signs__[0]]
  end

  it 'should return empty list if no sign name is found or passed empty string'
    let names = Call(g:__func__, '', g:__signs__[0])

    Expect type(names) == type([])
    Expect names == []

    let bundle = Call(g:__bundle_func__)
    let names = Call(g:__func__, bundle, '^__never_match__')

    Expect type(names) == type([])
    Expect names == []
  end

end


describe 's:extract_placed_ids()'

  before
    let g:__func__ = 's:extract_placed_ids'
    let g:__bundle_func__ = 's:placed_bundle'
    let g:__signs__ = s:toggle_sign_defs(1)
    let g:__ids__ = s:toggle_sign_placement(g:__signs__)
  end

  after
    call s:toggle_sign_placement([])
    call s:toggle_sign_defs(0)

    unlet g:__func__
    unlet g:__bundle_func__
    unlet g:__signs__
    unlet g:__ids__
  end

  it 'should return empty list if no sign in buffer'
    call s:toggle_sign_placement([])

    let bundle = Call(g:__bundle_func__, bufnr('%'))
    let ids = Call(g:__func__, bundle, g:__signs__[0])

    Expect type(ids) == type([])
    Expect len(ids) == 0
  end

  it 'should extract id of sign matched passed pattern from strings by s:placed_bundle()'
    let bundle = Call(g:__bundle_func__, bufnr('%'))
    let ids = Call(g:__func__, bundle, g:__signs__[0])

    Expect type(ids) == type([])
    Expect len(ids) == 1
    Expect ids == [g:__ids__[0]]
  end

  it 'should extract all id of sign if passed empty pattern'
    let bundle = Call(g:__bundle_func__, bufnr('%'))
    let ids = Call(g:__func__, bundle, '')

    Expect type(ids) == type([])
    Expect len(ids) == len(g:__ids__)
    Expect sort(ids, 'n') == sort(deepcopy(g:__ids__), 'n')
  end

end


describe 's:generate_id()'

  before
    let g:__func__ = 's:generate_id'
    let g:__signs__ = s:toggle_sign_defs(1)
  end

  after
    call s:toggle_sign_defs(0)

    unlet g:__func__
    unlet g:__signs__
  end

  it 'should generate id=1 if no sign in buffer'
    Expect Call(g:__func__) == 1
  end

  it 'should generate next number of max id in buffer'
    let max_id = 10

    for id in [7, max_id, 1]
      execute printf('sign place %s line=%s name=%s buffer=%s', id, 1, g:__signs__[0], bufnr('%'))
    endfor

    Expect Call(g:__func__) == max_id + 1
  end

  it 'should random and less than 100000 number if max number exceeded 100000'
    let max_id = 100010

    execute printf('sign place %s line=%s name=%s buffer=%s', max_id, 1, g:__signs__[0], bufnr('%'))

    Expect Call(g:__func__) <= 100000
  end

end


describe 's:name_with_mark()'

  it 'should return sign name embeded mark name'
    Expect Call('s:name_with_mark', 'a') == (Ref('s:sign')['prefix']).'a'
  end

end


describe 's:pattern()'

  it 'should return pattern for searching sign'
    Expect Call('s:pattern') == '\C^'.(Ref('s:sign'))['prefix']
  end

end


describe 's:placed_bundle()'

  before
    let g:__func__ = 's:placed_bundle'
    let g:__signs__ = s:toggle_sign_defs(1)
    let g:__ids__ = s:toggle_sign_placement(g:__signs__)
  end

  after
    call s:toggle_sign_placement([])
    call s:toggle_sign_defs(0)

    unlet g:__func__
    unlet g:__signs__
    unlet g:__ids__
  end

  it 'should return placed sign info in designated buffer as single string crumb'
    let bundle = Call(g:__func__, bufnr('%'))

    Expect type(bundle) == type('')
    Expect bundle != ''
    for sign_name in g:__signs__
      Expect bundle =~# sign_name
    endfor
  end

  it 'should return strings not contained sign info if no sign in buffer'
    call s:toggle_sign_placement([])
    let bundle = Call(g:__func__, bufnr('%'))

    Expect type(bundle) == type('')
    Expect bundle != ''
    for sign_name in g:__signs__
      Expect bundle !~# sign_name
    endfor
  end

end


describe 's:to_mark_name()'

  it 'should return only mark name from sign name'
    Expect Call('s:to_mark_name', (Ref('s:sign'))['prefix'].'a') == 'a'
  end

end


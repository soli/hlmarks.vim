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


describe 'reorder_spec()'

  before
    let g:__o_displaying_marks = g:hlmarks_displaying_marks
    let g:__o_sort_stacked_signs = g:hlmarks_sort_stacked_signs
    let g:__o_stacked_signs_order = g:hlmarks_stacked_signs_order

    let local_sign = Ref('s:sign')
    let g:__o_sign_prefix = local_sign.prefix
    let local_sign.prefix = 'SLF_'
    call Set('s:sign', local_sign)

    let g:__sign_spec_tmpl__ = {
      \ 'marks':  [ [10, 'SLF_a'], [11, 'SLF_b'] ],
      \ 'others': [ [21, 'OTS_2'], [20, 'OTS_1'] ],
      \ 'order':  [ 1, 0, 0, 1 ]
      \ }
    let g:hlmarks_displaying_marks = 'ba'
  end

  after
    let g:hlmarks_displaying_marks = g:__o_displaying_marks
    let g:hlmarks_sort_stacked_signs = g:__o_sort_stacked_signs
    let g:hlmarks_stacked_signs_order = g:__o_stacked_signs_order

    let local_sign = Ref('s:sign')
    let local_sign.prefix = g:__o_sign_prefix
    call Set('s:sign', local_sign)

    unlet g:__o_displaying_marks
    unlet g:__o_sort_stacked_signs
    unlet g:__o_stacked_signs_order
    unlet g:__o_sign_prefix
    unlet g:__sign_spec_tmpl__
  end

  it 'should not sort and signs of self are always placed under signs of others'
    let g:hlmarks_sort_stacked_signs = 0
    let g:hlmarks_stacked_signs_order = 0
    let expected = [ [10, 'SLF_a'], [11, 'SLF_b'], [21, 'OTS_2'], [20, 'OTS_1'] ]

    Expect hlmarks#sign#reorder_spec(g:__sign_spec_tmpl__).ordered == expected
  end

  it 'should sort and signs of self are always placed under signs of others'
    let g:hlmarks_sort_stacked_signs = 1
    let g:hlmarks_stacked_signs_order = 0
    let expected = [ [11, 'SLF_b'], [10, 'SLF_a'], [21, 'OTS_2'], [20, 'OTS_1'] ]

    Expect hlmarks#sign#reorder_spec(g:__sign_spec_tmpl__).ordered == expected
  end

  it 'should not sort and signs of self/others are placed same order'
    let g:hlmarks_sort_stacked_signs = 0
    let g:hlmarks_stacked_signs_order = 1
    let expected = [ [10, 'SLF_a'], [21, 'OTS_2'], [20, 'OTS_1'], [11, 'SLF_b'] ]

    Expect hlmarks#sign#reorder_spec(g:__sign_spec_tmpl__).ordered == expected
  end

  it 'should sort and signs of self/others are placed same order'
    let g:hlmarks_sort_stacked_signs = 1
    let g:hlmarks_stacked_signs_order = 1
    let expected = [ [11, 'SLF_b'], [21, 'OTS_2'], [20, 'OTS_1'], [10, 'SLF_a'] ]

    Expect hlmarks#sign#reorder_spec(g:__sign_spec_tmpl__).ordered == expected
  end

  it 'should not sort and signs of self are always placed above signs of others'
    let g:hlmarks_sort_stacked_signs = 0
    let g:hlmarks_stacked_signs_order = 2
    let expected = [ [21, 'OTS_2'], [20, 'OTS_1'], [10, 'SLF_a'], [11, 'SLF_b'] ]

    Expect hlmarks#sign#reorder_spec(g:__sign_spec_tmpl__).ordered == expected
  end

  it 'should sort and signs of self are always placed above signs of others'
    let g:hlmarks_sort_stacked_signs = 1
    let g:hlmarks_stacked_signs_order = 2
    let expected = [ [21, 'OTS_2'], [20, 'OTS_1'], [11, 'SLF_b'], [10, 'SLF_a'] ]

    Expect hlmarks#sign#reorder_spec(g:__sign_spec_tmpl__).ordered == expected
  end

end


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


describe 's:extract_placed_specs'

  before
    let g:__func__ = 's:extract_placed_specs'
    let g:__bundle_func__ = 's:placed_bundle'
    let g:__sign_spec_tmpl__ = {
      \ 'marks': [],
      \ 'others': [],
      \ 'all': [],
      \ 'ids': [],
      \ 'order': []
      \ }

    " line-no, id, name
    " Note: Signs are placed following order, AND appears in bundle(sign place
    "       buffer=n) with INVERSE order.
    let g:__sign_specs__ = [
      \ [1, 12, 'MYS_b'],
      \ [1, 11, 'MYS_a'],
      \ [2, 26, 'OTS_2'],
      \ [2, 22, 'MYS_d'],
      \ [2, 21, 'MYS_c'],
      \ [2, 25, 'OTS_1'],
      \ [3, 32, 'OTS_4'],
      \ [3, 31, 'OTS_3'],
      \ ]

    for spec in g:__sign_specs__
      execute 'sign define '.spec[2]
      execute printf('sign place %s line=%s name=%s buffer=%s', spec[1], spec[0], spec[2], bufnr('%'))
    endfor
  end

  after
    sign unplace *
    for spec in g:__sign_specs__
      execute 'sign undefine '.spec[2]
    endfor

    unlet g:__func__
    unlet g:__bundle_func__
    unlet g:__sign_spec_tmpl__
    unlet g:__sign_specs__
  end

  it 'should return empty spec-hash if no sign in buffer (line-no specified)'
    sign unplace *
    let bundle = Call(g:__bundle_func__, bufnr('%'))

    Expect Call(g:__func__, bundle, 1, '^MYS') == g:__sign_spec_tmpl__
  end

  it 'should extract spec-hash contains both(self,others) signs (line-no specified)'
    let bundle = Call(g:__bundle_func__, bufnr('%'))
    let expected = {
      \ 'marks':  [ [22, 'MYS_d'], [21, 'MYS_c'] ],
      \ 'others': [ [26, 'OTS_2'], [25, 'OTS_1'] ],
      \ 'all':    [ [26, 'OTS_2'], [22, 'MYS_d'], [21, 'MYS_c'], [25, 'OTS_1'] ],
      \ 'ids':    [ 25, 21, 22, 26 ],
      \ 'order':  [ 0, 1, 1, 0 ]
      \ }

    Expect Call(g:__func__, bundle, 2, '^MYS') == expected
  end

  it 'should extract spec-hash only contains only signs of self (line-no specified)'
    let bundle = Call(g:__bundle_func__, bufnr('%'))
    let expected = {
      \ 'marks':  [ [12, 'MYS_b'], [11, 'MYS_a'] ],
      \ 'others': [],
      \ 'all':    [ [12, 'MYS_b'], [11, 'MYS_a'] ],
      \ 'ids':    [ 11, 12 ],
      \ 'order':  [ 1, 1 ]
      \ }

    Expect Call(g:__func__, bundle, 1, '^MYS') == expected
  end

  it 'should extract spec-hash only contains only signs of others (line-no specified)'
    let bundle = Call(g:__bundle_func__, bufnr('%'))
    let expected = {
      \ 'marks':  [],
      \ 'others': [ [32, 'OTS_4'], [31, 'OTS_3'] ],
      \ 'all':    [ [32, 'OTS_4'], [31, 'OTS_3'] ],
      \ 'ids':    [ 31, 32 ],
      \ 'order':  [ 0, 0 ]
      \ }

    Expect Call(g:__func__, bundle, 3, '^MYS') == expected
  end

  it 'should extract all signs as line-no => spec-hash (line-no = 0)'
    let bundle = Call(g:__bundle_func__, bufnr('%'))
    let expected = {
      \ '1': {
        \ 'marks':  [ [12, 'MYS_b'], [11, 'MYS_a'] ],
        \ 'others': [],
        \ 'all':    [ [12, 'MYS_b'], [11, 'MYS_a'] ],
        \ 'ids':    [ 11, 12 ],
        \ 'order':  [ 1, 1 ]
        \ },
      \ '2': {
        \ 'marks':  [ [22, 'MYS_d'], [21, 'MYS_c'] ],
        \ 'others': [ [26, 'OTS_2'], [25, 'OTS_1'] ],
        \ 'all':    [ [26, 'OTS_2'], [22, 'MYS_d'], [21, 'MYS_c'], [25, 'OTS_1'] ],
        \ 'ids':    [ 25, 21, 22, 26 ],
        \ 'order':  [ 0, 1, 1, 0 ]
        \ },
      \ '3': {
        \ 'marks':  [],
        \ 'others': [ [32, 'OTS_4'], [31, 'OTS_3'] ],
        \ 'all':    [ [32, 'OTS_4'], [31, 'OTS_3'] ],
        \ 'ids':    [ 31, 32 ],
        \ 'order':  [ 0, 0 ]
        \ }
      \ }

    Expect Call(g:__func__, bundle, 0, '^MYS') == expected
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


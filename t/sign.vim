execute 'source ' . expand('%:p:h') . '/t/_common/helpers.vim'

runtime! plugin/hlmarks.vim

call vspec#hint({'scope': 'hlmarks#sign#scope()', 'sid': 'hlmarks#sign#sid()'})

describe 's:fix_format'

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


describe 's:sign_names_sorter'

  it 'should sort according to list of character order'
    SKIP 'Currently unable to test.'
  end

end


describe 's:defined_bundle'

  before
    sign define '__test__'
  end

  after
    sign undefine '__test__'
  end

  it 'should return currently defined signs as single string crumb'
    let bundle = Call('s:defined_bundle')

    Expect type(bundle) == type('') 
    Expect bundle != '' 
    Expect bundle =~# '__test__'
  end

end


describe 's:extract_chars'

  it 'should extract designated character class from passed strings'
    let target = 'ABCdef123<>.[]'

    Expect Call('s:extract_chars', 'lower', target) == 'def'
    Expect Call('s:extract_chars', 'upper', target) == 'ABC'
    Expect Call('s:extract_chars', 'number', target) == '123'
    Expect Call('s:extract_chars', 'symbol', target) == '<>.[]'
  end

  it 'should extract no character from empty string'
    let target = ''

    Expect Call('s:extract_chars', 'lower', target) == ''
    Expect Call('s:extract_chars', 'upper', target) == ''
    Expect Call('s:extract_chars', 'number', target) == ''
    Expect Call('s:extract_chars', 'symbol', target) == ''
  end

end


describe 's:extract_defined_names'

  before
    let g:__func__ = 's:extract_defined_names'
    let g:__crumb__ = join([
      \ 'sign __test__Error text=xx linehl=__test__ErrorLine texthl=__test__ErrorSign',
      \ 'sign __test__Warning text=!! linehl=__test__WarningLine texthl=__test__WarningSign',
      \ 'sign __test__StyleError text=S> linehl=__test__StyleErrorLine texthl=__test__StyleErrorSign',
      \ 'sign __test__StyleWarning text=S> linehl=__test__StyleWarningLine texthl=__test__StyleWarningSign'
      \ ], "\n")
    let g:__pat__ = '^__test__'
  end

  after
    unlet g:__func__
    unlet g:__crumb__
    unlet g:__pat__
  end

  it 'should extarct sign names from strings by s:defined_bundle()'
    let names = Call(g:__func__, g:__crumb__, g:__pat__)

    Expect type(names) == type([])
    Expect len(names) == 4
    for name in names
      Expect name =~# g:__pat__
    endfor
  end

  it 'should return empty list if no sign name is found or passed empty string'
    let names = Call(g:__func__, '', g:__pat__)

    Expect type(names) == type([])
    Expect names == []

    let names = Call(g:__func__, g:__crumb__, '^__never_match__')

    Expect type(names) == type([])
    Expect names == []
  end

end


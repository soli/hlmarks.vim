execute 'source ' . expand('%:p:h') . '/t/_common/helpers.vim'

runtime! plugin/hlmarks.vim

call vspec#hint({'scope': 'hlmarks#buffer#scope()', 'sid': 'hlmarks#buffer#sid()'})


describe 's:bundle()'

  it 'should return buffer list info as single string crumb'
    let bundle = Call('s:bundle')

    Expect type(bundle) == type('')
    Expect bundle != ''
  end

end


execute 'source ' . expand('%:p:h') . '/t/_common/helpers.vim'

runtime! plugin/hlmarks.vim

call vspec#hint({'scope': 'hlmarks#buffer#scope()', 'sid': 'hlmarks#buffer#sid()'})


describe 'numbers()'

  it 'should return all buffer numbers'
    let numbers = hlmarks#buffer#numbers()

    Expect type(numbers) == type([])
    Expect len(numbers) >= 1
    for bnum in numbers
      Expect type(bnum) == type(1)
    endfor
  end

end


describe 's:bundle()'

  it 'should return buffer list info as single string crumb'
    let bundle = Call('s:bundle')

    Expect type(bundle) == type('')
    Expect bundle != ''
  end

end


describe 's:extract_numbers()'

  it 'should extract more than one buffer numbers from strings by s:bundle() in startup'
    let bundle = Call('s:bundle')
    let extracted = Call('s:extract_numbers', bundle)

    Expect type(extracted) == type([])
    Expect len(extracted) >= 1
    for bnum in extracted
      Expect type(bnum) == type(1)
    endfor
  end

end


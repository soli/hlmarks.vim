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


describe 's:buffer_bundle()'

  it 'should return buffer list info as single string crumb'
    let bundle = Call('s:buffer_bundle')

    Expect type(bundle) == type('')
    Expect bundle != ''
  end

end


describe 's:extract_buffer_number()'

  it 'should extract more than one buffer numbers from strings by s:buffer_bundle() in startup'
    let bundle = Call('s:buffer_bundle')
    let extracted = Call('s:extract_buffer_number', bundle)

    Expect type(extracted) == type([])
    Expect len(extracted) >= 1
    for bnum in extracted
      Expect type(bnum) == type(1)
    endfor
  end

end


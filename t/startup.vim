execute 'source ' . expand('%:p:h') . '/t/_common/helpers.vim'

runtime! plugin/hlmarks.vim


describe 'plugin/hlmarks.vim'

  it 'should be loaded'
    Expect exists('g:loaded_hlmarks') to_be_true
    Expect g:loaded_hlmarks == 1
  end

  it 'should provide <Plug>(hlmarks-xxx)'
    Expect maparg('<Plug>(hlmarks-activate)', 'n')            =~# '\V:<C-U>call hlmarks#activate_plugin()<CR>'
    Expect maparg('<Plug>(hlmarks-inactivate)', 'n')          =~# '\V:<C-U>call hlmarks#inactivate_plugin()<CR>'
    Expect maparg('<Plug>(hlmarks-reload)', 'n')              =~# '\V:<C-U>call hlmarks#reload_plugin()<CR>'
    Expect maparg('<Plug>(hlmarks-refresh-signs)', 'n')       =~# '\V:<C-U>call hlmarks#refresh_signs()<CR>'
    Expect maparg('<Plug>(hlmarks-automark)', 'n')            =~# '\V:<C-U>call hlmarks#set_mark()<CR>'
    Expect maparg('<Plug>(hlmarks-remove-marks-line)', 'n')   =~# '\V:<C-U>call hlmarks#remove_marks_on_line()<CR>'
    Expect maparg('<Plug>(hlmarks-remove-marks-buffer)', 'n') =~# '\V:<C-U>call hlmarks#remove_marks_on_buffer()<CR>'
  end

  it 'should define commands'
    Expect len(_capture('command HlMarksOn')) != 1
    Expect len(_capture('command HlMarksOff')) != 1
  end

end
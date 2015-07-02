execute 'source ' . expand('%:p:h') . '/t/_common/test_helpers.vim'

runtime! plugin/hlmarks.vim

call vspec#hint({'scope': 'hlmarks#cache#scope()', 'sid': 'hlmarks#cache#sid()'})



function! s:Reg(subject)
  return _Reg_('__t__', a:subject)
endfunction


function! s:Local(subject)
  call _HandleLocalDict_('s:cache', a:subject)
endfunction



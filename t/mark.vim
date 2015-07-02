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


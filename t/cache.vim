execute 'source ' . expand('%:p:h') . '/t/_common/test_helpers.vim'

runtime! plugin/hlmarks.vim

call vspec#hint({'scope': 'hlmarks#cache#scope()', 'sid': 'hlmarks#cache#sid()'})


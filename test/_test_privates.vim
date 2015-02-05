let g:owl_success_message_format = "%l:[Success] %e %m"
let g:owl_failure_message_format = "%l:[Failure] %e"

let s:target = 'autoload/hlmarks.vim'


function! s:test_d()
  let owl_SID = owl#filename_to_SID(s:target)

  OwlCheck s:mark_pos('a') == []

endfunction




" function! s:test_duplicate_global_to_local()
"   let owl_SID = owl#filename_to_SID(s:target)

"   let key_defined = 'test_duplicate_global_to_local_defined'
"   let key_undefined = 'test_duplicate_global_to_local_undefined'

"   let g_name_defined = 'g:' . key_defined
"   let g_name_undefined = 'g:' . key_undefined

"   unlet! {g_name_defined}
"   unlet! {g_name_undefined}


"   let g_value_defined = 'defined'
"   let g_value_undefined = 'undefined'

"   let {g_name_defined} = g_value_defined

"   OwlEqual s:duplicate_global_to_local(key_defined, g_value_defined), 0
"   OwlEqual get(s:, key_defined, 'failed'), g_value_defined

"   " check undefined...
"   " check case defined is changed->reset...

"   " should unlet s:?

"   unlet! {g_name_defined}
"   unlet! {g_name_undefined}
" endfunction




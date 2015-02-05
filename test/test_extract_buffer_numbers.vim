let g:owl_success_message_format = "%l:[Success] %e %m"
let g:owl_failure_message_format = "%l:[Failure] %e"

let s:target = 'autoload/hlmarks/buffer.vim'

function! s:test_extract_numbers()
  let owl_SID = owl#filename_to_SID(s:target)

  let bundle = join([
    \ '',
    \ '  1 #    "test_reorder_sign_spec.vim"   行 42',
    \ '  2 %a   "~/Dropbox/@Settings/vim/_vim/bundle/hlmarks.vim/autoload/hlmarks.vim" 行 297',
    \ '  3      "/Volumes/ESD/@dropps/配送状況.txt" 行 0',
    \ '  4u h   "[quickrun output]"            行 0',
    \ '  5u     "[無名]"                       行 1',
    \ '  6   =  "/Volumes/ESD/t1.txt"          行 0',
    \ '  7u     "[無名]"                       行 1',
    \ '  8u     "[無名]"                       行 1',
    \ ''
    \ ], "\n")

  let expected = [1,2,3,4,5,6,7,8]
  OwlEqual s:extract_numbers(bundle), expected
endfunction


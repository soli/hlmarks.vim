let g:owl_success_message_format = "%l:[Success] %e %m"
let g:owl_failure_message_format = "%l:[Failure] %e"

let s:target = 'autoload/hlmarks/sign.vim'

function! s:test_extract_defined_names()
  let owl_SID = owl#filename_to_SID(s:target)

  let empty_bundle = ''
  let bundle = join([
    \ 'sign SyntasticError text=xx linehl=SyntasticErrorLine texthl=SyntasticErrorSign',
    \ 'sign SyntasticWarning text=!! linehl=SyntasticWarningLine texthl=SyntasticWarningSign',
    \ 'sign SyntasticStyleError text=S> linehl=SyntasticStyleErrorLine texthl=SyntasticStyleErrorSign',
    \ 'sign SyntasticStyleWarning text=S> linehl=SyntasticStyleWarningLine texthl=SyntasticStyleWarningSign'
    \ ], "\n")
  let nomatch_pattern = '_never_find_me_'
  let match_pattern = '^Syntastic'

  let e_empty = []
  OwlEqual s:extract_defined_names(empty_bundle, match_pattern), e_empty

  let e_nomatch = []
  OwlEqual s:extract_defined_names(bundle, nomatch_pattern), e_nomatch

  let e_match = ['SyntasticError', 'SyntasticWarning', 'SyntasticStyleError', 'SyntasticStyleWarning']
  OwlEqual s:extract_defined_names(bundle, match_pattern), e_match
endfunction


let g:owl_success_message_format = "%l:[Success] %e %m"
let g:owl_failure_message_format = "%l:[Failure] %e"

let s:target = 'autoload/hlmarks/sign.vim'

function! s:test_extract_placed_ids()
  let owl_SID = owl#filename_to_SID(s:target)

  let bundle = [
    \ '',
    \ '--- サイン ---',
    \ '[NULL] のサイン:',
    \ '     行=2  識別子=52  名前=SignName_a',
    \ '     行=99  識別子=99  名前=AnotherName',
    \ '     行=10  識別子=108  名前=SignName_b'
    \ ]
  let bundle_en = [
    \ '',
    \ '--- Signs ---',
    \ 'Signs for [NULL]:',
    \ '     line=2  id=52  name=SignName_a',
    \ '     line=99  id=99  name=AnotherName',
    \ '     line=10  id=108  name=SignName_b'
    \ ]
  let nomatch_pattern = '_never_match'
  let match_pattern = '^SignName_'
  let allmatch_pattern = ''

  let v_no_sign = join(bundle[0:1] + [''], "\n")
  let e_no_sign = []
  OwlEqual s:extract_placed_ids(v_no_sign, match_pattern), e_no_sign

  let v_one_sign = join(bundle[0:4] + [''], "\n")
  let e_one_sign = [52]
  OwlEqual s:extract_placed_ids(v_one_sign, match_pattern), e_one_sign

  let v_two_sign = join(bundle[0:5] + [''], "\n")
  let e_two_sign = [52, 108]
  OwlEqual s:extract_placed_ids(v_two_sign, match_pattern), e_two_sign

  let v_no_matched_sign = join(bundle[0:5] + [''], "\n")
  let e_no_matched_sign = []
  OwlEqual s:extract_placed_ids(v_no_matched_sign, nomatch_pattern), e_no_matched_sign

  let v_all_matched_sign = join(bundle[0:5] + [''], "\n")
  let e_all_matched_sign = [52, 99, 108]
  OwlEqual s:extract_placed_ids(v_all_matched_sign, allmatch_pattern), e_all_matched_sign


  let v_en_two_sign = join(bundle_en[0:5] + [''], "\n")
  let e_en_two_sign = [52, 108]
  OwlEqual s:extract_placed_ids(v_en_two_sign, match_pattern), e_en_two_sign
endfunction


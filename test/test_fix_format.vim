let g:owl_success_message_format = "%l:[Success] %e %m"
let g:owl_failure_message_format = "%l:[Failure] %e"

let s:target = 'autoload/hlmarks/sign.vim'

function! s:test_fix_format()
  let owl_SID = owl#filename_to_SID(s:target)

  let spf  = '%m'

  let v_empty = ''
  let e_empty = spf
  OwlEqual s:fix_format(v_empty, spf), e_empty

  let v_no_spf = '>'
  let e_no_spf = spf . '>'
  OwlEqual s:fix_format(v_no_spf, spf), e_no_spf

  let v_over_no_spf = '>='
  let e_over_no_spf = spf . '>'
  OwlEqual s:fix_format(v_over_no_spf, spf), e_over_no_spf


  let v_only = spf
  let e_only = spf
  OwlEqual s:fix_format(v_only, spf), e_only

  let v_correct_h = spf . '>'
  let e_correct_h = spf . '>'
  OwlEqual s:fix_format(v_correct_h, spf), e_correct_h

  let v_correct_t = '>' . spf
  let e_correct_t = '>' . spf
  OwlEqual s:fix_format(v_correct_t, spf), e_correct_t

  let v_over_h = spf . '>='
  let e_over_h = spf . '>'
  OwlEqual s:fix_format(v_over_h, spf), e_over_h

  let v_over_m = '>' . spf . '>'
  let e_over_m = '>' . spf
  OwlEqual s:fix_format(v_over_m, spf), e_over_m

  let v_over_t = '>=' . spf
  let e_over_t = '>' . spf
  OwlEqual s:fix_format(v_over_t, spf), e_over_t

  let v_dup_only = spf . spf
  let e_dup_only = spf
  OwlEqual s:fix_format(v_dup_only, spf), e_dup_only

  let v_dup_h = spf . spf . '>'
  let e_dup_h = spf . '>'
  OwlEqual s:fix_format(v_dup_h, spf), e_dup_h

  let v_dup_t = '>' . spf . spf
  let e_dup_t = '>' . spf
  OwlEqual s:fix_format(v_dup_t, spf), e_dup_t


  let v_multi = spf . '>' . spf
  let e_multi = spf . '>'
  OwlEqual s:fix_format(v_multi, spf), e_multi

  let v_multi_4 = '>' . spf . '+' . spf
  let e_multi_4 = '>' . spf
  OwlEqual s:fix_format(v_multi_4, spf), e_multi_4

  let v_multi_4_over = spf . '>=' . spf . '+'
  let e_multi_4_over = spf . '>'
  OwlEqual s:fix_format(v_multi_4_over, spf), e_multi_4_over
endfunction


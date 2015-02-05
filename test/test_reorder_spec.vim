let g:owl_success_message_format = "%l:[Success] %e %m"
let g:owl_failure_message_format = "%l:[Failure] %e"

let s:target = 'autoload/hlmarks/sign.vim'

function! s:test_reorder_spec()
  let owl_SID = owl#filename_to_SID(s:target)

  let o_displaying_marks = g:hlmarks_displaying_marks
  let o_sort_stacked_signs = g:hlmarks_sort_stacked_signs
  let o_stacked_signs_order = g:hlmarks_stacked_signs_order

  let spec_orig = {
    \ 'marks': [
      \ [10, 'HighlightMarks_a'], [11, 'HighlightMarks_b'], [14, 'HighlightMarks_c'], [15, 'HighlightMarks_d'], [17, 'HighlightMarks_e']
    \ ],
    \ 'others': [
      \ [30, 'OthersName_1'], [20, 'OthersName_2'], [40, 'OthersName_3']
    \ ],
    \ 'all': [
      \ [10, 'HighlightMarks_a'], [30, 'OthersName_1'], [11, 'HighlightMarks_b'], [14, 'HighlightMarks_c'], [15, 'HighlightMarks_d'],
      \ [20, 'OthersName_2'], [40, 'OthersName_3'], [17, 'HighlightMarks_e']
    \ ],
    \ 'ids': [17, 40, 20, 15, 14, 11, 30, 10],
    \ 'order': [1, 0, 1, 1, 1, 0, 0, 1]
    \ }

  let g:hlmarks_displaying_marks = 'gfedcba'


  " sign-sort=no / mark-sign-order=bottom
  let g:hlmarks_sort_stacked_signs = 0
  let g:hlmarks_stacked_signs_order = 0
  let spec = deepcopy(spec_orig, 1)
  let expected = deepcopy(spec_orig, 1)
  let expected.ordered = [
    \ [10, 'HighlightMarks_a'], [11, 'HighlightMarks_b'], [14, 'HighlightMarks_c'], [15, 'HighlightMarks_d'], [17, 'HighlightMarks_e'],
    \ [30, 'OthersName_1'], [20, 'OthersName_2'], [40, 'OthersName_3']
    \ ]
  OwlEqual hlmarks#sign#reorder_spec(spec), expected


  " sign-sort=yes / mark-sign-order=bottom
  let g:hlmarks_sort_stacked_signs = 1
  let g:hlmarks_stacked_signs_order = 0
  let spec = deepcopy(spec_orig, 1)
  let expected = deepcopy(spec_orig, 1)
  let expected.marks = [
    \ [17, 'HighlightMarks_e'], [15, 'HighlightMarks_d'], [14, 'HighlightMarks_c'], [11, 'HighlightMarks_b'], [10, 'HighlightMarks_a']
    \ ]
  let expected.ordered = [
    \ [17, 'HighlightMarks_e'], [15, 'HighlightMarks_d'], [14, 'HighlightMarks_c'], [11, 'HighlightMarks_b'], [10, 'HighlightMarks_a'],
    \ [30, 'OthersName_1'], [20, 'OthersName_2'], [40, 'OthersName_3']
    \ ]
  OwlEqual hlmarks#sign#reorder_spec(spec), expected


  " sign-sort=no / mark-sign-order=as-is
  let g:hlmarks_sort_stacked_signs = 0
  let g:hlmarks_stacked_signs_order = 1
  let spec = deepcopy(spec_orig, 1)
  let expected = deepcopy(spec_orig, 1)
  let expected.marks = []
  let expected.others = []
  let expected.ordered = [
    \ [10, 'HighlightMarks_a'], [30, 'OthersName_1'], [11, 'HighlightMarks_b'], [14, 'HighlightMarks_c'], [15, 'HighlightMarks_d'],
    \ [20, 'OthersName_2'], [40, 'OthersName_3'], [17, 'HighlightMarks_e']
    \ ]
  OwlEqual hlmarks#sign#reorder_spec(spec), expected


  " sign-sort=yes / mark-sign-order=as-is
  let g:hlmarks_sort_stacked_signs = 1
  let g:hlmarks_stacked_signs_order = 1
  let spec = deepcopy(spec_orig, 1)
  let expected = deepcopy(spec_orig, 1)
  let expected.marks = []
  let expected.others = []
  let expected.ordered = [
    \ [17, 'HighlightMarks_e'], [30, 'OthersName_1'], [15, 'HighlightMarks_d'], [14, 'HighlightMarks_c'], [11, 'HighlightMarks_b'],
    \ [20, 'OthersName_2'], [40, 'OthersName_3'], [10, 'HighlightMarks_a']
    \ ]
  OwlEqual hlmarks#sign#reorder_spec(spec), expected


  " sign-sort=no / mark-sign-order=top
  let g:hlmarks_sort_stacked_signs = 0
  let g:hlmarks_stacked_signs_order = 2
  let spec = deepcopy(spec_orig, 1)
  let expected = deepcopy(spec_orig, 1)
  let expected.ordered = [
    \ [30, 'OthersName_1'], [20, 'OthersName_2'], [40, 'OthersName_3'],
    \ [10, 'HighlightMarks_a'], [11, 'HighlightMarks_b'], [14, 'HighlightMarks_c'], [15, 'HighlightMarks_d'], [17, 'HighlightMarks_e']
    \ ]
  OwlEqual hlmarks#sign#reorder_spec(spec), expected


  " sign-sort=yes / mark-sign-order=top
  let g:hlmarks_sort_stacked_signs = 1
  let g:hlmarks_stacked_signs_order = 2
  let spec = deepcopy(spec_orig, 1)
  let expected = deepcopy(spec_orig, 1)
  let expected.marks = [
    \ [17, 'HighlightMarks_e'], [15, 'HighlightMarks_d'], [14, 'HighlightMarks_c'], [11, 'HighlightMarks_b'], [10, 'HighlightMarks_a']
    \ ]
  let expected.ordered = [
    \ [30, 'OthersName_1'], [20, 'OthersName_2'], [40, 'OthersName_3'],
    \ [17, 'HighlightMarks_e'], [15, 'HighlightMarks_d'], [14, 'HighlightMarks_c'], [11, 'HighlightMarks_b'], [10, 'HighlightMarks_a']
    \ ]
  OwlEqual hlmarks#sign#reorder_spec(spec), expected


  let g:hlmarks_displaying_marks = o_displaying_marks
  let g:hlmarks_sort_stacked_signs = o_sort_stacked_signs
  let g:hlmarks_stacked_signs_order = o_stacked_signs_order
endfunction


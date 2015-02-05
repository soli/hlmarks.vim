let g:owl_success_message_format = "%l:[Success] %e %m"
let g:owl_failure_message_format = "%l:[Failure] %e"

let s:target = 'autoload/hlmarks/sign.vim'

function! s:test_extract_placed_specs()
  let owl_SID = owl#filename_to_SID(s:target)

  let bundle = join([
    \ '',
    \ '--- サイン ---',
    \ '[NULL] のサイン:',
    \ '     行=2  識別子=52  名前=SignName_x',
    \ '     行=50  識別子=17  名前=SignName_e',
    \ '     行=50  識別子=40  名前=OthersName_3',
    \ '     行=50  識別子=20  名前=OthersName_2',
    \ '     行=50  識別子=15  名前=SignName_d',
    \ '     行=50  識別子=14  名前=SignName_c',
    \ '     行=50  識別子=11  名前=SignName_b',
    \ '     行=50  識別子=30  名前=OthersName_1',
    \ '     行=50  識別子=10  名前=SignName_a',
    \ '     行=99  識別子=108  名前=SignName_y',
    \ '     行=111  識別子=201  名前=OthersName_4',
    \ '',
    \ ], "\n")
  let pattern = '^SignName_'


  let line_no = 10
  let expected = {
    \ 'marks': [],
    \ 'others': [],
    \ 'all': [],
    \ 'ids': [],
    \ 'order': []
    \ }
  OwlEqual s:extract_placed_specs(bundle, line_no, pattern), expected


  let line_no = 50
  let expected = {
    \ 'marks': [
      \ [10, 'SignName_a'], [11, 'SignName_b'], [14, 'SignName_c'], [15, 'SignName_d'], [17, 'SignName_e']
    \ ],
    \ 'others': [
      \ [30, 'OthersName_1'], [20, 'OthersName_2'], [40, 'OthersName_3']
    \ ],
    \ 'all': [
      \ [10, 'SignName_a'], [30, 'OthersName_1'], [11, 'SignName_b'], [14, 'SignName_c'], [15, 'SignName_d'],
      \ [20, 'OthersName_2'], [40, 'OthersName_3'], [17, 'SignName_e']
    \ ],
    \ 'ids': [17, 40, 20, 15, 14, 11, 30, 10],
    \ 'order': [1, 0, 1, 1, 1, 0, 0, 1]
    \ }
  OwlEqual s:extract_placed_specs(bundle, line_no, pattern), expected


  let line_no = 0
  let expected = {
    \ '2': {
    \ 'marks': [
      \ [52, 'SignName_x']
    \ ],
    \ 'others': [],
    \ 'all': [
      \ [52, 'SignName_x']
    \ ],
    \ 'ids': [52],
    \ 'order': [1]
    \ },
    \ '50': {
    \ 'marks': [
      \ [10, 'SignName_a'], [11, 'SignName_b'], [14, 'SignName_c'], [15, 'SignName_d'], [17, 'SignName_e']
    \ ],
    \ 'others': [
      \ [30, 'OthersName_1'], [20, 'OthersName_2'], [40, 'OthersName_3']
    \ ],
    \ 'all': [
      \ [10, 'SignName_a'], [30, 'OthersName_1'], [11, 'SignName_b'], [14, 'SignName_c'], [15, 'SignName_d'],
      \ [20, 'OthersName_2'], [40, 'OthersName_3'], [17, 'SignName_e']
    \ ],
    \ 'ids': [17, 40, 20, 15, 14, 11, 30, 10],
    \ 'order': [1, 0, 1, 1, 1, 0, 0, 1]
    \ },
    \ '99': {
    \ 'marks': [
      \ [108, 'SignName_y']
    \ ],
    \ 'others': [],
    \ 'all': [
      \ [108, 'SignName_y']
    \ ],
    \ 'ids': [108],
    \ 'order': [1]
    \ }
    \ }
  OwlEqual s:extract_placed_specs(bundle, line_no, pattern), expected
endfunction


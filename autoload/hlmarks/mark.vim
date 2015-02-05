scriptencoding utf-8
 
" Preserve 'cpoptions'
let s:save_cpo = &cpo
set cpo&vim


" ==============================================================================
" Mark
" ==============================================================================
" ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

let s:mark = {
  \ 'cache_name': 'marks',
  \ 'available': 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.''`^<>[]{}()"',
  \ 'global': 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
  \ 'invisible_marks': ['(', ')', '{', '}'],
  \ 'enable_set_manually': 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ''`^<>[]',
  \ 'enable_remove': 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.`^<>[]"',
  \ 'unable_remove': '''(){}',
  \ 'enable_automark': 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
  \ 'set_automatically': '"^.(){}'
  \ }

function! s:_export_()
  return s:
endfunction

"
" Public.
" ______________________________________________________________________________
" ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

"
" Determine whether mark can be removed or not.
"
" Param:  [String] mark: candidate mark 
" Return: [Number] determination (1/0)
"
function! hlmarks#mark#can_remove(mark)
  return strlen(a:mark) == 1 && stridx(s:mark.unable_remove, a:mark) < 0
endfunction

"
" Get marks in current buffer that should be signed.
"
" Return: [Dict] mark specs (see extract())
"
function! hlmarks#mark#covered()
  return s:extract(s:bundle(g:hlmarks_displaying_marks), bufnr('%'))
endfunction

"
" Generate mark name that is not used.
"
" Note:   Candidate of marks are a-Z regardless of displaying marks.
"
function! hlmarks#mark#generate_name()
  let candidate_marks = s:mark.enable_automark
  let bundle = s:bundle(candidate_marks)
  let placed_marks = join(keys(s:extract(bundle)), '')
  let mark = ''

  let last_idx = strlen(candidate_marks) - 1
  for idx in range(0, last_idx)
    let candidate = candidate_marks[idx : idx]
    if stridx(placed_marks, candidate) < 0
      let mark = candidate
      break
    endif
  endfor

  if empty(mark)
    execute 'echohl WarningMsg | echo "Used up all marks!" | echohl None'
  endif

  return mark
endfunction

"
" Generate mark state.
"
" Return: [Dict] mark state (see extract())
"
function! hlmarks#mark#generate_state()
  return s:extract(s:bundle(g:hlmarks_displaying_marks), bufnr('%'))
endfunction

"
" Get mark state cache.
"
" Return: [String] cache (see generate_state())
"
function! hlmarks#mark#get_cache()
  return hlmarks#cache#get(s:mark.cache_name, '')
endfunction

"
" Determine whether mark is valid or not.
"
" Param:  [String] mark: candidate mark 
" Return: [Number] determination (1/0)
"
function! hlmarks#mark#is_valid(mark)
  return strlen(a:mark) == 1 && stridx(s:mark.enable_set_manually, a:mark) >= 0
endfunction

"
" Fix mark position(buffer/line-no).
"
" Param:  [String] mark: mark
" Return: [List] list as [buffer-no, line-no]
"
function! hlmarks#mark#pos(mark)
  " Return value of getpos is [buffer-no, line-no, column-pos, offset].
  let [buffer_no, line_no; _null_] = getpos("'" . a:mark)

  " Buffer number is always '0' when mark is other than A-Z0-9.
  if line_no != 0 && buffer_no == 0
    let buffer_no = bufnr('%')
  endif

  return [buffer_no, line_no]
endfunction

"
" Remove mark.
"
" Param:  [String] mark_seq: designated mark or mark sequence(e.g. abAS..)
"
function! hlmarks#mark#remove(mark_seq)
  " Note: Suppress errors for unloaded/deleted buffer related to A-Z0-9 marks.
  silent! execute printf('delmarks %s', a:mark_seq)
endfunction

"
" Remove marks on current buffer.
"
function! hlmarks#mark#remove_all()

  " Remove except marks A-Z0-9.
  silent execute 'delmarks!'

  let bundle = s:bundle(s:mark.global)
  let placed_marks = keys(s:extract(bundle, bufnr('%')))

  call hlmarks#mark#remove(join(placed_marks, ''))
endfunction

"
" Remove marks on designated line.
"
" Param:  [Number] (a:1) line number (default='.')
" Return: [List] removed marks
"
function! hlmarks#mark#remove_on_line(...)
  let line_no = a:0 ? a:1 : line('.')
  let bundle = s:bundle(s:mark.enable_remove)
  let placed_marks = s:extract(bundle, bufnr('%'))
  let marks = []

  for [mark, placed_line_no] in items(placed_marks)
    if placed_line_no == line_no
      call add(marks, mark)
    endif
  endfor

  call hlmarks#mark#remove(join(marks, ''))

  return marks
endfunction

"
" execute native mark command.
"
" Param:  [String] mark: mark name
"
function! hlmarks#mark#set(mark)
  silent execute printf('normal %s%s', g:hlmarks_alias_native_mark_cmd, a:mark)
endfunction

"
" Set mark state cache.
"
" Param:  [String] (a:1) cache(default=generate_state())
"
function! hlmarks#mark#set_cache(...)
  call hlmarks#cache#set(s:mark.cache_name, (a:0 ? a:1 : hlmarks#mark#generate_state()))
endfunction

"
" Private.
" ______________________________________________________________________________
" ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

"
" Get strings of placed marks.
"
" Param:  [String] (a:1) characters sequence of marks(default=all)
" Return: [String] bundle that contains placed marks
" Note:   Basically, this function extract marks in CURRENT buffer,
"         but GLOBAL marks(A-Z0-9) are included. (See :marks command help)
"
function! s:bundle(...)
  let mark_chars = a:0 ? a:1 : s:mark.available

  redir => bundle
    " Note: Suppress errors for unloaded/deleted buffer related to A-Z0-9 marks.
    silent! execute printf('marks %s', mark_chars)
  redir END

  " Append specs of invisible(not be presented with :marks command) marks if needed.
  let addings = []
  for mark in s:mark.invisible_marks
    if stridx(mark_chars, mark) >= 0
      let [_null_, line_no] = hlmarks#mark#pos(mark)
      call add(addings, printf(' %s  %d  0  (invisible)', mark, line_no))
    endif
  endfor

  return join(([bundle] + addings), "\n")
endfunction

"
" Extract mark name/line-no from bundle that is taken from 'marks' command.
"
" Param:  [String] bundle: bundle of placed marks
" Param:  [Number] (a:1) target buffer number (default=regardless-of-buffer)
" Return: [Dict] dictionary of extracted mark specs as {mark-name: line-no}
"
function! s:extract(bundle, ...)
  let marks = {}
  let buffer_no = a:0 ? a:1 : 0

  for crumb in split(a:bundle, "\n")
    let matched = matchlist(crumb, '\v^\s+(\S)\s+(\d+)\s+')
    if !empty(matched) && (!buffer_no || hlmarks#mark#pos(matched[1])[0] == buffer_no)
      let marks[matched[1]] = str2nr(matched[2], 10)
    endif
  endfor

  return marks
endfunction


" Restore 'cpoptions'
let &cpo = s:save_cpo
unlet s:save_cpo

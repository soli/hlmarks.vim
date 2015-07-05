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
  \ 'availables': 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.''`^<>[]{}()"',
  \ 'globals': 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789',
  \ 'invisibles': ['(', ')', '{', '}'],
  \ 'togglables': 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ''`<>[]',
  \ 'deletables': 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.^<>[]"',
  \ 'automarkables': 'abcdefghijklmnopqrstuvwxyz'
  \ }

function! s:_export_()
  return s:
endfunction

"
" [For testing] Get SID of this file.
"
function! hlmarks#mark#sid()
  return maparg('<SID>', 'n')
endfunction
nnoremap <SID>  <SID>

"
" [For testing] Get local variables in this file.
"
function! hlmarks#mark#scope()
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
  return strlen(a:mark) == 1 && stridx(s:mark.deletables, a:mark) >= 0
endfunction

"
" Get marks in current buffer that should be signed.
"
" Return: [Dict] mark specs (see extract())
"
function! hlmarks#mark#covered()
  return s:extract(s:bundle(g:hlmarks_displaying_marks), 0)
endfunction

"
" Generate mark name that is not used.
"
" Note:   Mark candidates are a-z(except global) regardless of displaying marks.
"
function! hlmarks#mark#generate_name()
  let candidate_marks = s:mark.automarkables
  let bundle = s:bundle(candidate_marks)
  let placed_marks = join(keys(s:extract(bundle, 1)), '')
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
  return s:extract(s:bundle(g:hlmarks_displaying_marks), 0)
endfunction

"
" Get mark state cache.
"
" Return: [Dict] cache (see generate_state())
"
function! hlmarks#mark#get_cache()
  return hlmarks#cache#get(s:mark.cache_name, {})
endfunction

"
" Determine whether mark is valid or not.
"
" Param:  [String] mark: candidate mark 
" Return: [Number] determination (1/0)
"
function! hlmarks#mark#is_valid(mark)
  return strlen(a:mark) == 1 && stridx(s:mark.togglables, a:mark) >= 0
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
" Note:   Marks that can be remove by 'delmarks {chars}' command are as below.
"           abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.^<>[]"
"             (Note that double-quote(") must be escaped)
"             (Note that angle-bracket(<>") is NOT removed 'delmarks!' command)
"         Marks that can not be removed are as below.
"           `'(){}
"             (Note that back-quote(`) is presented as single-quote(') in 'marks' command.
"         Be care, marks that can be removed by command are NOT same as marks
"         that can be placed manually.
"
function! hlmarks#mark#remove(mark_seq)
  let mark_seq = escape(a:mark_seq, '"')

  " Note: Suppress errors for unloaded/deleted buffer related to A-Z0-9 marks.
  silent! execute printf('delmarks %s', mark_seq)
endfunction

"
" Remove marks on current buffer.
"
function! hlmarks#mark#remove_all()

  " Remove except marks A-Z0-9.(see also notes in remove())
  silent! delmarks!
  silent! delmarks <>\"

  let bundle = s:bundle(s:mark.globals)
  let placed_marks = keys(s:extract(bundle, 0))

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
  let bundle = s:bundle(s:mark.deletables)
  let placed_marks = s:extract(bundle, 0)
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
  " Not suppress errors for user.
  silent execute printf('normal %s%s', g:hlmarks_alias_native_mark_cmd, a:mark)
endfunction

"
" Set mark state cache.
"
" Param:  [Dict] (a:1) cache(default=generate_state())
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
" Note:   Basically, this function extract marks in CURRENT buffer only with
"         designated marks(if exists), but GLOBAL marks(A-Z0-9) in other buffer
"         are included if they designated and exists. (See :marks command help)
"
function! s:bundle(...)
  " Note: Double-quote must be escaped in 'marks' command.
  let mark_chars = escape((a:0 ? a:1 : s:mark.availables), '"')

  " If execute mark command with invisibles, it cause error, so unmerge them.
  let invisibles = []
  for mark in s:mark.invisibles
    if stridx(mark_chars, mark) >= 0
      call add(invisibles, mark)
      let mark_chars = substitute(mark_chars, mark, '', 'g')
    endif
  endfor

  if mark_chars != ''
    redir => bundle
      " Note: Suppress errors for unloaded/deleted buffer related to A-Z0-9 marks.
      silent! execute printf('marks %s', mark_chars)
    redir END
  else
    let bundle = ''
  endif

  " Append specs of invisible(not be presented with :marks command) marks if needed.
  let addings = []
  for mark in invisibles
    let [_null_, line_no] = hlmarks#mark#pos(mark)
    call add(addings, printf(' %s  %d  0  (invisible)', mark, line_no))
  endfor

  return join(([bundle] + addings), "\n")
endfunction

"
" Extract mark name/line-no from bundle that is taken from 'marks' command.
"
" Param:  [String] bundle: bundle of placed marks
" Param:  [Number] include_globals_in_other_buffer: as variable name
" Return: [Dict] dictionary of extracted mark specs as {mark-name: line-no}
" Note:   Passed bundle(perhaps created by s:bundle()) DO NOT include marks
"         other than current buffer, BUT global marks in other buffer are
"         contained if they are designated in s:bundle() invocation.
"
function! s:extract(bundle, include_globals_in_other_buffer)
  let marks = {}
  let buffer_no = bufnr('%')
  let include_other = a:include_globals_in_other_buffer

  for crumb in split(a:bundle, "\n")
    let matched = matchlist(crumb, '\v^\s+(\S)\s+(\d+)\s+')
    if !empty(matched) && (include_other || hlmarks#mark#pos(matched[1])[0] == buffer_no)
      let marks[matched[1]] = str2nr(matched[2], 10)
    endif
  endfor

  return marks
endfunction


" Restore 'cpoptions'
let &cpo = s:save_cpo
unlet s:save_cpo

scriptencoding utf-8
 
" Preserve 'cpoptions'
let s:save_cpo = &cpo
set cpo&vim


" ==============================================================================
" Util
" ==============================================================================
" ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

let s:util = {}

function! s:_export_()
  return s:
endfunction

"
" [For testing] Get SID of this file.
"
function! hlmarks#util#sid()
  return maparg('<SID>', 'n')
endfunction
nnoremap <SID>  <SID>

"
" [For testing] Get local variables in this file.
"
function! hlmarks#util#scope()
  return s:
endfunction

"
" Public.
" ______________________________________________________________________________
" ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

"
" [xxx] Import objects.
"
" Param:  [List] libs: list of object name
" Param:  [Dict] context: dictionary that objects are imported
" Note:   Imported object name is camelcased
"          e.g. 'object' => 'Object', 'snake_case' => 'SnakeCase'
"
function! hlmarks#util#export(libs, context)
  let exported = {}
  for lib in a:libs
    let lib_name = join(map(
      \ split(lib, '_'), 'toupper(v:val[0:0]) . tolower(v:val[1:-1])'
      \ ), '_')
    let exported[lib_name] = call('hlmarks#' . lib . '#export', [])
  endfor
  call extend(a:context, exported)
endfunction

"
" [For debugging purpose] Invoke function with arbitrary args.
"
" Param:  [String] func_path: path to target function (see below note)
" Param:  [Any] (a:000) arguments
" Note:   Argument 'func_path' must be either case as below.
"           1) path#..#path#func
"           2) path#..#path#s:func
"           3) path#..#path#s:dict.func
"           - SHOULD BE designate enough path segments, otherwise incorrect
"             function will be invoked.
"           - In case 3(dictionary function), target must implement function
"             that export local-variable='s:' and is named 'export'.
"         Ref about SID/SNR
"           => http://mattn.kaoriya.net/software/vim/20090826003359.htm
"
function! hlmarks#util#invoke_func(func_path, ...)

  " Case 1
  if stridx(a:func_path, 's:') < 0
    call hlmarks#util#log(call(a:func_path, a:000), 1)
    return
  endif

  let path = split(a:func_path, '#')
  let func_name = remove(path, -1)
  let file_path = join(path, '/') . '.vim'

  if stridx(func_name, '.') < 0
    let [dict_name, func_name] = ['', func_name[2:-1]]
  else
    let [dict_name, func_name] = split(func_name, '\v\.')
    let dict_name = dict_name[2:-1]
  endif

  let script_info = s:script_info(file_path)
  if empty(script_info)
    call s:warn('Script is not found!')
    return
  endif

  " Case 2
  if empty(dict_name)
    let Func = s:func_ref(script_info[0], func_name)

    if !Func
      call s:warn('Script-local function is not found!')
      return
    endif

    let result = call(Func, a:000)

  " Case 3
  else
    let Exporter = s:func_ref(script_info[0], '_export_')

    if empty(Exporter)
      call s:warn('Exporter is required for invocation of dictionary function!')
      return
    endif

    let sl_context = call(Exporter, [])
    let dict = get(sl_context, dict_name, {})

    if empty(dict) || !has_key(dict, func_name)
      call s:warn('Function is not found in dictionary!')
      return
    endif

    let result = call(get(dict, func_name), a:000, dict)
  endif

  call hlmarks#util#log('Invoked in: ' . script_info[1], 1)
  call hlmarks#util#log(result)
endfunction

"
" [For debugging purpose] Present message.
"
" Param:  [Any] message: contents
" Param:  [Number] (a:1) flag whether clear console or not
"                        (optional, default=no)
" Note:   Use VimConsole plugin if installed.
"
function! hlmarks#util#log(message, ...)
  if exists(":VimConsole")
    if a:0 && a:1
      call vimconsole#clear()
    endif
    call vimconsole#winopen()
    call vimconsole#log(a:message)
    call vimconsole#redraw()
  else
    echo string(a:message)
  endif
endfunction

"
" Private.
" ______________________________________________________________________________
" ''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

"
" Get function reference.
"
" Param:  [Number] sid: SID
" Param:  [String] func_name: function name except prefix(s:,...)
" Return: [FuncRef] function reference or 0 if failed
"
function! s:func_ref(sid, func_name)
  try
    let Func = function(printf('<SNR>%s_%s', a:sid, a:func_name))
  catch /\v./
    return 0
  endtry

  return Func
endfunction

"
" Get script ID matches with designated file path
"
" Param:  [String] file_path: part of path
" Return: [List] SID and path ([SID, path] or empty(if not found))
" Note:   Only one id that is found first is retured.
"         Find every time, no use cache.
"
function! s:script_info(file_path)
  redir => bundle
    silent! scriptnames
  redir END

  let pattern = '\v^\s*(\d+):\s+(.+' . escape(a:file_path, '-_./\') . ')$'
  for crumb in split(bundle, "\n")
    let matched = matchlist(crumb, pattern)
    if !empty(matched)
      return matched[1:2]
    endif
  endfor

  return []
endfunction

"
" Display warning message.
"
" Param:  [String] message: message
"
function! s:warn(message)
  execute printf('echohl WarningMsg | echo "%s" | echohl None', a:message)
endfunction


" Restore 'cpoptions'
let &cpo = s:save_cpo
unlet s:save_cpo

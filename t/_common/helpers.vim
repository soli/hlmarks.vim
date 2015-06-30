function! _capture(cmd, ...)
  redir => crumb
    silent execute a:cmd
  redir END

  let want_array = a:0 ? a:1 : 1

  return want_array ? split(crumb, "\n") : crumb
endfunction



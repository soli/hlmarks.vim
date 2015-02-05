let s:loops = 10000

function! benchmark#invoke(f_ref, ...)
  let m = matchlist(string(a:f_ref), '^function(''<.\+>\d\+_\(.\+\)'')')
  echo '----- ' . (empty(m) ? string(a:f_ref) : m[1])
  let i = 0
  let start_time = reltime()
  while i < s:loops
    let args = deepcopy(a:000, 1)
    let r = call(a:f_ref, args)
    let i += 1
  endwhile
  let end_time = split(reltimestr(reltime(start_time)))[0]
  echo ' result: ' . string(r)
  echo ' time  : ' . end_time . ' (' . i . ' loops)'
endfunction


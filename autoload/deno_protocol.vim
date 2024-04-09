function! deno_protocol#edit() abort
  let l:deno_url = expand('<afile>')->s:normalize()
  if expand('%')->s:normalize() !=# l:deno_url
    " Do nothing when the buffer name has changed from <afile>
    return
  endif
  let l:content = s:fetch(l:deno_url)
  setlocal modifiable
  0,$delete _
  call setline(1, l:content)
  setlocal nomodifiable nomodified
  filetype detect
endfunction

function! deno_protocol#read() abort
  let l:deno_url = expand('<afile>')->s:normalize()
  let l:content = s:fetch(l:deno_url)
  call append('.', l:content)
endfunction

function! deno_protocol#get(deno_url) abort
  return s:fetch(a:deno_url)
endfunction

function! s:normalize(s) abort
  return a:s->substitute('\\', '/', 'g')
endfunction

let s:script_path = expand('<sfile>:p:h') .. '/deno_protocol.ts'

function! s:fetch(deno_url) abort
  let l:deno = get(g:, 'deno_protocol_deno_command', 'deno')
  let l:fix_import = get(g:, 'deno_protocol_fix_relative_import', v:true)
  let l:exe = exepath(l:deno)
  if l:exe ==# ''
    throw printf('[deno-protocol] command not found: %s', l:deno)
  endif
  let l:command = [
        \ l:exe,
        \ 'run',
        \ '--no-check',
        \ '--no-config',
        \ '--no-lock',
        \ '--allow-net',
        \ '--',
        \ s:script_path,
        \ a:deno_url,
        \ l:fix_import ? '--fix-import' : '',
        \]
  let l:res = s:job_sync(l:command)
  if l:res.exitval !=# 0
    throw printf('[deno-protocol] %s: %s', l:res.err->join(), a:deno_url)
  endif
  return l:res.out
endfunction

function! s:job_sync(command) abort
  let l:out = []
  let l:err = []
  let l:job = job_start(a:command, #{
        \ mode: 'nl',
        \ in_io: 'null',
        \ out_cb: {ch, msg -> l:out->add(msg)},
        \ err_cb: {ch, msg -> l:err->add(msg)},
        \})
  while l:job->job_status() ==# 'run'
    sleep 50ms
  endwhile
  return extend(#{out: l:out, err: l:err}, l:job->job_info(), 'keep')
endfunction

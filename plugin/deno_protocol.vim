if exists('g:loaded_deno_protocol')
  finish
endif
let g:loaded_deno_protocol = 1

if !exists('g:deno_protocol_deno_command')
  let g:deno_protocol_deno_command = 'deno'
endif

if !exists('g:deno_protocol_fix_relative_import')
  let g:deno_protocol_fix_relative_import = v:true
endif

augroup deno_protocol
  autocmd!
  autocmd BufReadCmd deno:/* ++nested call deno_protocol#edit()
  autocmd FileReadCmd deno:/* ++nested call deno_protocol#read()
augroup END

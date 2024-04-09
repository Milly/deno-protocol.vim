# deno-protocol.vim

Allow opening a remote file with `deno:/` format. It is the protocol used for
`deno lsp`.

## Supported formats

- `deno:/http/host/path...`
- `deno:/https/host/path...`

## Requirements

`deno` command must be available in your system.

You can specify the path to the `deno` to `g:deno_protocol_deno_command`. The
default value is "deno". It will be searched from `$PATH`.

```vim
:let g:deno_protocol_deno_command = '/path/to/bin/deno'
```

## Usage

Open a remote file with `deno:/` format.

```vim
:e deno:/https/deno.land/std\%400.221.0/assert/assert_equals.ts
```

Note that URL encoding is decoded. The following will give the same result as
above.

```vim
:e deno:/https/deno.land/std@0.221.0/assert/assert_equals.ts
```

## Import replacement

If `g:deno_protocol_fix_relative_import` is TRUE, relative imports of remote
files will be replaced with absolute URLs. The default value is `v:true`.

# License

[MIT](./LICENSE).

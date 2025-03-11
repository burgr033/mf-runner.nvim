# mf-runner.nvim
`mf-runner.nvim` is a simple and easy runner for makefiles.

## Install

### Lazy

```lua
{
        "burgr033/mf-runner.nvim",
        cmd = { "MFROpen", "MFRRun", "MFREdit" },
        dependencies = {
            "folke/snacks.nvim",
        },
        opts = {},
},

```

## Configuration

no configuration needed. You need a Makefile in your current cwd.

## Commands

* `:MFROpen` opens a snacks picker for the targets in the detected Makefile

* `:MFRRun` can be used to tab through specific Makefile targets without the use of
snacks picker. If you use generic targets, you could use it for |mf-runner-mappings|

* `MFREdit` opens a Makefile in a new buffer or if none is detected will open a new Buffer for creating one.

## Mappings

If you use generic build targets you could just map e.g.

```lua
vim.keymap.set('n', '<leader>mf', 'MFRRun build')
```

## Motivation

I was looking through so many different code-runner plugins which were either
1. too complicated for my use cases (overseer.nvim, compiler.nvim, etc...)
2. were not really os independant (path escaping etc.)
3. were configured in the neovim config and not in the project itself

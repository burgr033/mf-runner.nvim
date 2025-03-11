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

No configuration needed. You just need a Makefile in your current working directory.

## Commands

* `:MFROpen` - Opens a snacks picker for the targets in the detected Makefile
* `:MFRRun <target>` - Run a specific Makefile target. Supports tab completion for available targets
* `:MFREdit` - Edit the existing Makefile or create a new one if none exists

## Mappings

If you use generic build targets, you could set up key mappings like:

```lua
vim.keymap.set('n', '<leader>mb', ':MFRRun build<CR>', { desc = "Run Makefile build target" })
vim.keymap.set('n', '<leader>mt', ':MFRRun test<CR>', { desc = "Run Makefile test target" })
vim.keymap.set('n', '<leader>mc', ':MFRRun clean<CR>', { desc = "Run Makefile clean target" })
```

## Features

- OS-independent path handling
- Recursive Makefile include parsing
- Intuitive UI with snacks.nvim integration
- Command output display in floating window
- Tab completion for Makefile targets

## Motivation

I was looking through many different code-runner plugins which were either:
1. Too complicated for my use cases (overseer.nvim, compiler.nvim, etc.)
2. Not truly OS-independent (issues with path escaping)
3. Configured in the Neovim config rather than in the project itself

This plugin aims to be a simple, lightweight solution that just works.

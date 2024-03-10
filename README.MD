# mf-runner.nvim
This plugin is going to be the only "code-runner" you need.
## Install
### Lazy
```lua
{
    "burgr033/mf-runner.nvim",
    cmd = { "MFROpen", "MFRRun", "MFRCreate" },
    dependencies = { "nvim-telescope/telescope.nvim", "akinsho/toggleterm.nvim" }
    opts = {},
},

```
## Usage

* `:MFROpen` opens up the telescope picker.
* `:MFRRun <TAB>` tab trough targets of current Makefile 
* `:MFRCreate` create Makefile 


## Motivation

I was looking through so many different code-runner plugins which were either
1. too complicated for my use cases (overseer.nvim, compiler.nvim, etc...)
2. were not really os independant (path escaping etc.)
3. were configured in the neovim config and not in the project itself

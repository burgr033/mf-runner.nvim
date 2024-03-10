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

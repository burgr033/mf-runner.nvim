local utils = require "mf-runner.utils"
local cmd = vim.api.nvim_create_user_command
local M = {}
local snacks_available, _ = pcall(require, "snacks")

--- setup function
M.setup = function()
  if snacks_available then
    cmd("MFROpen", function() require("mf-runner.picker").open_picker() end, { desc = "Open mf-runner" })
  end
  cmd(
    "MFREdit",
    function() require("mf-runner.backend").edit_makefile() end,
    { desc = "Create a makefile file in the current directory" }
  )
  cmd("MFRRun", function(tbl) require("mf-runner.backend").run_makefile(tbl.args) end, {
    desc = "Run Makefile",
    nargs = 1,
    complete = function() return utils.parseMakefile() or {} end,
  })
end

return M

local utils = require "mf-runner.utils"
local cmd = vim.api.nvim_create_user_command
local M = {}
local telescopeAvailable = pcall(require, "telescope")
M.setup = function()
  if telescopeAvailable then
    cmd("MFROpen", function() require("mf-runner.telescope").show() end, { desc = "Open mf-runner" })
  end
  cmd(
    "MFREdit",
    function() require("mf-runner.backend").edit_makefile() end,
    { desc = "Create a makefile file in the current directory" }
  )
  cmd("MFRRun", function(tbl) require("mf-runner.backend").run_makefile(tbl.args) end, {
    desc = "Run Makefile",
    nargs = 1,
    complete = function()
      local options = utils.parseMakefile()
      return options
    end,
  })
end

return M

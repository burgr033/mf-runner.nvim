local utils = require "mf-runner.utils"
local cmd = vim.api.nvim_create_user_command
local M = {}

--- Initialize the plugin and create user commands
---@return nil
M.setup = function()
  local snacks_available, _ = pcall(require, "snacks")

  if snacks_available then
    cmd(
      "MFROpen",
      function() require("mf-runner.picker").open_picker() end,
      { desc = "Open mf-runner picker for build targets (Makefile/justfile)" }
    )
  end

  cmd(
    "MFREdit",
    function() require("mf-runner.backend").edit_build_file() end,
    { desc = "Edit existing build file or create a new one (Makefile/justfile)" }
  )

  cmd("MFRRun", function(tbl) require("mf-runner.backend").run_build_target(tbl.args) end, {
    desc = "Run specified build target (Makefile/justfile)",
    nargs = 1,
    complete = function()
      local targets, _ = utils.parse_build_file()
      return targets or {}
    end,
  })
end

return M

local M = {}

local start = vim.health.start or vim.health.report_start
local ok = vim.health.ok or vim.health.report_ok
local error = vim.health.error or vim.health.report_error
local info = vim.health.info or vim.health.report_info

function M.check()
  start "mf-runner.nvim"
  if vim.fn.executable "make" == 1 then
    ok "The command `make` is available"
  else
    error "The command `make` is not available"
  end

  local telescope_available, _ = pcall(require, "telescope")
  local toggleterm_available, _ = pcall(require, "toggleterm")

  start "optional dependencies for mf-runner.nvim"
  if not telescope_available then
    info "Telescope is not available, Commands like `MFROpen` won't work"
  else
    ok "Telescope is available"
  end
  if not toggleterm_available then
    info "Toggleterm is not available, Commands will be executed with bang instead of toggleterm"
  else
    ok "Toggleterm is available"
  end
end

return M

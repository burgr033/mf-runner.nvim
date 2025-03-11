local M = {}

local start = vim.health.start or vim.health.report_start
local ok = vim.health.ok or vim.health.report_ok
local error = vim.health.error or vim.health.report_error
local info = vim.health.info or vim.health.report_info

--- check health function
function M.check()
  start "mf-runner.nvim"
  if vim.fn.executable "make" == 1 then
    ok "The command `make` is available"
  else
    error "The command `make` is not available"
  end

  local snacks_available, _ = pcall(require, "snacks")

  start "optional dependencies for mf-runner.nvim"
  if not snacks_available then
    info "Snacks is not available, Commands like `MFROpen` won't work"
  else
    ok "Snacks is available (for picker and floating window)"
  end
end

return M

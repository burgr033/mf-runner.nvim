local M = {}

local start = vim.health.start or vim.health.report_start
local ok = vim.health.ok or vim.health.report_ok
local warn = vim.health.warn or vim.health.report_warn
local error = vim.health.error or vim.health.report_error
local info = vim.health.info or vim.health.report_info

--- check health function
function M.check()
  start "mf-runner.nvim"

  local has_make = vim.fn.executable "make" == 1
  local has_just = vim.fn.executable "just" == 1

  if has_make then
    ok "The command `make` is available"
  else
    warn "The command `make` is not available"
  end

  if has_just then
    ok "The command `just` is available"
  else
    warn "The command `just` is not available"
  end

  if not has_make and not has_just then error "Neither `make` nor `just` is available. At least one is required." end

  local snacks_available, _ = pcall(require, "snacks")

  start "optional dependencies for mf-runner.nvim"
  if not snacks_available then
    info "Snacks is not available, Commands like `MFROpen` won't work"
  else
    ok "Snacks is available (for picker and floating window)"
  end
end

return M

--- Utils for mf-runner.nvim

local M = {}

--- Given a string, convert 'slash' to 'inverted slash' if on windows, and vice versa on UNIX.
-- Then return the resulting string.
---@param path string
---@return string|nil,nil
function M.os_path(path)
  if path == nil then return nil end
  -- Get the platform-specific path separator
  local separator = package.config:sub(1, 1)
  return string.gsub(path, "[/\\]", separator)
end

--- Given a path, open the file, extract all the Makefile keys,
--  and return them as a list.
---@return table targets
function M.parseMakefile()
  local filepath = M.os_path(vim.fn.getcwd() .. "/Makefile")
  local targets = {}
  local include_directives = {}
  local function processFile(filename)
    for line in io.lines(filename) do
      -- Ignore comments and variable assignments
      if not line:match "^%s*#" and not line:match "^%s*%w+%s*=%s*" and not line:match "^%s*%w+%s*:=%s*" then
        -- Match include directives
        local include_file = line:match "^%s*include%s+(.+)"
        if include_file then
          table.insert(include_directives, include_file)
        else
          -- Match target lines
          local target = line:match "^%s*([%w%-%._/]+)%s*:"
          if target then
            -- Check for phony targets
            if target ~= ".PHONY" then table.insert(targets, target) end
          end
        end
      end
    end
  end

  if vim.fn.filereadable(filepath) == 1 then
    -- Process main Makefile
    processFile(filepath)
    -- Process included Makefiles recursively
    for _, include_file in ipairs(include_directives) do
      processFile(include_file)
    end
  else
    vim.notify("File does not exist", vim.log.levels.INFO)
  end

  return targets
end

return M

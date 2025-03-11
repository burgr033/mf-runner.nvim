local M = {}

--- Given a string, convert 'slash' to 'inverted slash' if on windows, and vice versa on UNIX.
-- Then return the resulting string.
---@param path string
---@return string
function M.os_path(path)
  if path == nil then return nil end
  -- Get the platform-specific path separator
  local separator = package.config:sub(1, 1)
  return string.gsub(path, "[/\\]", separator)
end

--- Get the full path to the Makefile in the current working directory
---@return string filepath
function M.get_makefile_path() return M.os_path(vim.fn.getcwd() .. "/Makefile") end

--- Given a path, open the file, extract all the Makefile targets,
-- and return them as a list.
---@return table targets
function M.parseMakefile()
  local filepath = M.get_makefile_path()
  local targets = {}
  local include_directives = {}
  local processed_files = {} -- Track processed files to prevent cycles

  local function processFile(filename)
    -- Prevent infinite recursion with cycle detection
    if processed_files[filename] then return end
    processed_files[filename] = true

    local file = io.open(filename, "r")
    if not file then
      vim.notify("Could not open file: " .. filename, vim.log.levels.WARN)
      return
    end

    for line in file:lines() do
      -- Ignore comments and variable assignments
      if not line:match "^%s*#" and not line:match "^%s*%w+%s*=%s*" and not line:match "^%s*%w+%s*:=%s*" then
        -- Match include directives
        local include_file = line:match "^%s*include%s+(.+)"
        if include_file then
          -- Handle relative paths for includes
          if not vim.fn.fnamemodify(include_file, ":p:h"):match "^/" then
            include_file = vim.fn.fnamemodify(filename, ":h") .. "/" .. include_file
          end
          include_file = M.os_path(include_file)
          table.insert(include_directives, include_file)
        else
          -- Match target lines
          local target = line:match "^%s*([%w%-%._/]+)%s*:"
          if target and target ~= ".PHONY" then table.insert(targets, target) end
        end
      end
    end

    file:close()
  end

  if vim.fn.filereadable(filepath) == 1 then
    -- Process main Makefile
    processFile(filepath)
    -- Process included Makefiles recursively
    for _, include_file in ipairs(include_directives) do
      processFile(include_file)
    end
  else
    vim.notify("Makefile does not exist in the current directory", vim.log.levels.INFO)
  end

  return targets
end

return M

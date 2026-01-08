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

--- Detect which build file exists in the current directory
---@return string|nil file_type "makefile", "justfile", or nil
---@return string|nil error_msg Error message if both files exist
function M.detect_build_file()
  local cwd = vim.fn.getcwd()
  local makefile_path = M.os_path(cwd .. "/Makefile")
  local justfile_path = M.os_path(cwd .. "/justfile")

  local has_makefile = vim.fn.filereadable(makefile_path) == 1
  local has_justfile = vim.fn.filereadable(justfile_path) == 1

  if has_makefile and has_justfile then
    return nil, "Both Makefile and justfile exist. Please keep only one build file."
  elseif has_makefile then
    return "makefile", nil
  elseif has_justfile then
    return "justfile", nil
  else
    return nil, "No Makefile or justfile found in current directory"
  end
end

--- Get the full path to the Makefile in the current working directory
---@return string filepath
function M.get_makefile_path() return M.os_path(vim.fn.getcwd() .. "/Makefile") end

--- Get the full path to the justfile in the current working directory
---@return string filepath
function M.get_justfile_path() return M.os_path(vim.fn.getcwd() .. "/justfile") end

--- Parse a Justfile and extract all recipes
---@return table targets
function M.parseJustfile()
  local filepath = M.get_justfile_path()
  local targets = {}

  if vim.fn.filereadable(filepath) ~= 1 then
    vim.notify("justfile does not exist in the current directory", vim.log.levels.INFO)
    return targets
  end

  local file = io.open(filepath, "r")
  if not file then
    vim.notify("Could not open file: " .. filepath, vim.log.levels.WARN)
    return targets
  end

  for line in file:lines() do
    -- Ignore comments and variable assignments
    if not line:match "^%s*#" and not line:match "^%s*%w+%s*:=%s*" then
      -- Match recipe lines (target followed by dependencies and colon)
      -- Justfile recipes can have parameters, so we capture everything before :
      local target = line:match "^([%w%-%._]+)%s*[^:]*:"
      if target then table.insert(targets, target) end
    end
  end

  file:close()
  return targets
end

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

--- Parse the appropriate build file (Makefile or justfile) based on what exists
---@return table targets
---@return string|nil file_type "makefile" or "justfile"
function M.parse_build_file()
  local file_type, err = M.detect_build_file()

  if err then
    vim.notify(err, vim.log.levels.ERROR)
    return {}, nil
  end

  if not file_type then
    vim.notify("No build file found", vim.log.levels.INFO)
    return {}, nil
  end

  if file_type == "makefile" then
    return M.parseMakefile(), "makefile"
  elseif file_type == "justfile" then
    return M.parseJustfile(), "justfile"
  end

  return {}, nil
end

return M

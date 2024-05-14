--- ### Frontend for mf-runner.nvim

local M = {}

function M.show()
	-- dependencies
	local conf = require("telescope.config").values
	local actions = require "telescope.actions"
	local state = require "telescope.actions.state"
	local pickers = require "telescope.pickers"
	local finders = require "telescope.finders"
	local utils = require "mf-runner.utils"
	local options = utils.parseMakefile()
	--- On option selected → Run action depending of the language
	local function on_option_selected(prompt_bufnr)
		actions.close(prompt_bufnr)        -- Close Telescope on selection
		local selection = state.get_selected_entry()
		_G.mfrunner_redo = selection.value -- Save redo
		if selection then require("mf-runner.backend").run_makefile(selection.value) end
	end

	--- Show telescope
	local function open_telescope()
		pickers
				.new({}, {
					prompt_title = "mf-runner",
					results_title = "Options",
					finder = finders.new_table {
						results = options,
						entry_maker = function(entry)
							return {
								display = entry,
								value = entry,
								ordinal = entry,
							}
						end,
					},
					sorter = conf.generic_sorter(),
					attach_mappings = function(_, map)
						map("i", "<CR>", function(prompt_bufnr) on_option_selected(prompt_bufnr) end)
						map("n", "<CR>", function(prompt_bufnr) on_option_selected(prompt_bufnr) end)
						return true
					end,
				})
				:find()
	end
	open_telescope() -- Entry point
end

return M

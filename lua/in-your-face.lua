local M = {}
local id_chan, id_win, id_autocmd, id_buffer

---@class windows_opts
---@field y number
---@field x number

---@class opts
---@field windows windows_opts

local function file_exists(name)
	local f = io.open(name, "r")
	return f ~= nil and io.close(f)
end
local get_ansi_code = function(file)
	if (not file_exists(file)) then
		return "File not found"
	end
	local lines = ""
	for line in io.lines(file) do
		lines = lines .. line
	end
	return lines
end


---it opens a floating terminal
---@param opt opts
local create_floating_terminal = function(opt)
	id_buffer = vim.api.nvim_create_buf(true, true)
	vim.api.nvim_buf_set_name(id_buffer,"Doom Face")
	id_win = vim.api.nvim_open_win(id_buffer, true, {
		relative = "editor",
		style = "minimal",
		border = "rounded",
		row = opt.windows.y + 1,
		col = opt.windows.x,
		width = 48,
		height = 32,
	})
	id_chan = vim.api.nvim_open_term(id_buffer, {})
end


local function close()
	pcall(function ()
		if id_win ~= nil then
			vim.api.nvim_win_close(id_win, true)
		end
		if id_autocmd ~= nil then
			vim.api.nvim_del_autocmd(id_autocmd)
		end
		if id_buffer ~= nil then
			print(id_buffer)
			vim.api.nvim_buf_delete(id_buffer, { force = true })
		end
	end)
	id_autocmd = nil
	id_win = nil
	id_autocmd = nil
	id_buffer = nil
end

---@param opt opts
M.setup = function(opt)
	close()

	local id_last_win = vim.fn.win_getid()
	create_floating_terminal(opt)
	vim.api.nvim_set_current_win(id_last_win)
	local script_path = debug.getinfo(1, "S").source:sub(2):match(".*/")
	vim.api.nvim_chan_send(id_chan, get_ansi_code(script_path .. "../doom-guy-normal.txt"))

	id_autocmd = vim.api.nvim_create_autocmd("DiagnosticChanged", {
		callback = function(args)
			local diagnostics = args.data.diagnostics
			-- get count of errors
			local errors = 0
			for _, diagnostic in ipairs(diagnostics) do
				if diagnostic.severity == vim.diagnostic.severity.ERROR then
					errors = errors + 1
				end
			end
			if not pcall(function()
					if errors == 0 then
						vim.api.nvim_chan_send(id_chan, get_ansi_code(script_path .. "../doom-guy-normal.txt"))
						return
					end
					if errors < 3 then
						vim.api.nvim_chan_send(id_chan, get_ansi_code(script_path .. "../doom-guy-injured.txt"))
						return
					end
					if errors < 5 then
						vim.api.nvim_chan_send(id_chan, get_ansi_code(script_path .. "../doom-guy-major-injured.txt"))
						return
					end
					vim.api.nvim_chan_send(id_chan, get_ansi_code(script_path .. "../doom-guy-max-injured.txt"))
				end) then
				close()
			end
	end
})
end
return M

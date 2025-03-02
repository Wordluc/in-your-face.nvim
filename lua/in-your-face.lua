local M={}

---@class windows_opts
---@field x number
---@field y number

---@class opts
---@field windows windows_opts

local function file_exists (name)
	local f = io.open(name, "r")
	return f ~= nil and io.close(f)
end
local get_ansi_code = function (file)
	if (not file_exists(file)) then
		return "File not found"
	end
	local lines = ""
	for line in io.lines(file) do
		lines = lines..line
	end
	return lines
end


---it opens a floating terminal
---@param opt opts
---@return number id chan to send strings throught the terminal
local open_floating_terminal = function(opt)
	local buffer = vim.api.nvim_create_buf(true, true)
	local w=vim.api.nvim_open_win(buffer, true, {
		relative = "editor",
		style = "minimal",
		border = "rounded",
		row = opt.windows.y+1,
		col = opt.windows.x,
		width = 48,
		height = 32,
	})
	return vim.api.nvim_open_term(buffer,{})
end

---@param opt opts
M.setup=function (opt)
	local id_win=vim.fn.win_getid()
	local chan=open_floating_terminal(opt)
	vim.api.nvim_set_current_win(id_win)
	local script_path = debug.getinfo(1, "S").source:sub(2):match(".*/")
	vim.api.nvim_chan_send(chan,get_ansi_code(script_path.."../doom-guy-normal.txt"))
	vim.api.nvim_create_autocmd("DiagnosticChanged", {
		callback = function(args)
			local diagnostics = args.data.diagnostics
			-- get count of errors
			local errors = 0
			for _, diagnostic in ipairs(diagnostics) do
				if diagnostic.severity == vim.diagnostic.severity.ERROR then
					errors = errors + 1
				end
			end
			if errors==0 then
				vim.api.nvim_chan_send(chan,get_ansi_code(script_path.."../doom-guy-normal.txt"))
				return
			end
			if errors<3 then
				vim.api.nvim_chan_send(chan,get_ansi_code(script_path.."../doom-guy-injured.txt"))
				return
			end
			if errors<5 then
				vim.api.nvim_chan_send(chan,get_ansi_code(script_path.."../doom-guy-major-injured.txt"))
				return
			end
			vim.api.nvim_chan_send(chan,get_ansi_code(script_path.."../doom-guy-max-injured.txt"))
		end
	})
	end
return M

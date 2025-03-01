local M={}

---@class windows_opts
---@field x number
---@field y number
---@field w number
---@field h number

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
M.open_floating_terminal = function(opt)
	local buffer = vim.api.nvim_create_buf(true, true)
	local w=vim.api.nvim_open_win(buffer, true, {
		relative = "editor",
		style = "minimal",
		border = "rounded",
		row = opt.windows.y+1,
		col = opt.windows.x,
		width = opt.windows.w,
		height = opt.windows.h,
	})
	local chan=vim.api.nvim_open_term(buffer,{})
	vim.api.nvim_chan_send(chan,get_ansi_code("/home/luca/.local/share/nvim/lazy/in-your-face.nvim/lua/doom0.txt"))

end
return M

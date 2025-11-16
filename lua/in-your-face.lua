local M = {}
local max_madness = 10
local script_path = debug.getinfo(1, "S").source:sub(2):match(".*/") .. "../faces"
local ansi_faces = {}
local current_face = 0
---@type opts
local default_opts = {
	window = {
		x = vim.fn.winwidth(0) - 48,
		y = 0,
	},
	max_madness = 10
}

local id_chan, id_win, id_autocmd, id_buffer

---@class window_opts
---@field y number
---@field x number

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


---@class opts
---@field window window_opts?
---@field max_madness number?

---it opens a floating terminal
---@param window window_opts
local create_floating_terminal = function(window)
	M.close()
	id_buffer = vim.api.nvim_create_buf(true, true)
	vim.api.nvim_buf_set_name(id_buffer, "Doom Face")
	id_win = vim.api.nvim_open_win(id_buffer, true, {
		relative = "editor",
		style = "minimal",
		border = "rounded",
		row = window.y + 1,
		col = window.x,
		width = 48,
		height = 32,
	})
	id_chan = vim.api.nvim_open_term(id_buffer, {})
end


M.close = function()
	pcall(function()
		if id_win ~= nil then
			vim.api.nvim_win_close(id_win, true)
		end
		if id_autocmd ~= nil then
			vim.api.nvim_del_autocmd(id_autocmd)
		end
		if id_buffer ~= nil then
			vim.api.nvim_buf_delete(id_buffer, { force = true })
		end
	end)
	id_autocmd = nil
	id_win = nil
	id_autocmd = nil
	id_buffer = nil
	ansi_faces = {}
	current_face = -1
end

local function loadFaces()
	local ansi = {}
	for _, path in pairs(vim.split(vim.fn.glob(script_path .. "/*"), '\n', { trimempty = true })) do
		local gravity = vim.split(path, script_path .. "/", { plain = true })[2]
		gravity = vim.split(gravity, "-", { plain = true })[1]

		ansi[tonumber(gravity)] = get_ansi_code(path)
	end
	return ansi
end

local function updateFace()
	local errors = 0
	errors = vim.diagnostic.count()[vim.diagnostic.severity.ERROR]
	if errors == nil then
		errors = 0
	end
	if errors > max_madness then
		errors = max_madness
	end
	local faces_number = math.floor((#ansi_faces - 1) / max_madness * errors) + 1
	if faces_number ~= current_face then
		current_face = faces_number
		vim.api.nvim_chan_send(id_chan, ansi_faces[current_face])
	end
end

---@param opts opts?
M.setup = function(opts)
	if opts == nil then
		opts = default_opts
	end
	if opts.max_madness ~= nil then
		max_madness = opts.max_madness
	end

	local id_last_win = vim.fn.win_getid()
	create_floating_terminal(opts.window)
	vim.api.nvim_set_current_win(id_last_win)
	ansi_faces = loadFaces()
	updateFace()
	id_autocmd = vim.api.nvim_create_autocmd("DiagnosticChanged", {
		callback = function(_)
			updateFace()
		end
	})
end
return M

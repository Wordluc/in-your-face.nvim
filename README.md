# IN YOUR FACE neovim version


https://github.com/user-attachments/assets/bab6c724-1394-4b41-b89b-befd1db113e2


## Configuration 
```
return {
"Wordluc/in-your-face.nvim",
config=function ()
	vim.api.nvim_create_user_command('DoomFace', function()
		require("in-your-face").setup();
	end, { bang = true, nargs = '*' })
	vim.api.nvim_create_user_command('DoomFaceKill', function()
		require("in-your-face").close();
	end,{ bang = true, nargs = '*' })
end
}
```



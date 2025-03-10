# IN YOUR FACE neovim version
## Configuration 
```
return {
"Wordluc/in-your-face.nvim",
config=function ()
		vim.api.nvim_create_user_command('Try', function()
			local opt={
				windows={
					x=vim.fn.winwidth(0)-48,
					y=0
				},
			}
			require("in-your-face").setup(opt);
		end, { bang = true, nargs = '*' })
	end
}
```
## Faces
| errors = 0  | normal       | ![1](https://github.com/user-attachments/assets/eb8dc0f1-0828-4d30-9346-ec0a3c398126)|
|-------------|--------------|--------|
| errors < 3  | injured      | ![11](https://github.com/user-attachments/assets/cd3d86fb-2e8f-4320-bde7-a6440064e919)|
| errors < 5  | more injured | ![19](https://github.com/user-attachments/assets/8f01a58d-bc0e-4430-ade4-f13cc611fde0)|
|  errors >= 5 | max injured  | ![41](https://github.com/user-attachments/assets/36e9ad1e-1981-4713-95c8-df76c2d78fce)|
## Future Improvement
Allow to select your own faces for each errors range.

If you wanna do it now you have to overwrite the files `doom-guy-...txt`, you can use a golang program (inside the go directory) where you have to specify what image convert and where put the result.
  `go run .  "/home/foo/Downloads/11.png" "../doom-guy-injured.txt"`.
  
The size of the image has to be 48x32
## Show case
![image](https://github.com/user-attachments/assets/5da1cbdc-fbc6-4401-a598-4e8a10fc055e)
![image](https://github.com/user-attachments/assets/91478009-0f6a-4ceb-a542-3965b5f46d8d)



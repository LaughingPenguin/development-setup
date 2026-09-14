local function add_to_gitignore(picker)
	local item = picker:current()
	local path = item and (item.rename or item.file)
	if not path or path == "" then
		Snacks.notify.warn("No file selected", { title = "Git ignore" })
		return
	end

	local root = item.cwd or picker:cwd()
	local gitignore = root .. "/.gitignore"

	local content = ""
	local file = io.open(gitignore, "r")
	if file then
		content = file:read("*a")
		file:close()
	end

	-- Match Cursor/VSCode: relative path, no leading slash, escape `[`.
	local pattern = path:gsub("\\", "/"):gsub("^%./", ""):gsub("%[", "\\[")
	for line in content:gmatch("[^\n]+") do
		if line:gsub("\r$", "") == pattern then
			Snacks.notify.info("Already in .gitignore", { title = "Git ignore" })
			return
		end
	end

	local prefix = content ~= "" and content:sub(-1) ~= "\n" and "\n" or ""
	local out, err = io.open(gitignore, "a")
	if not out then
		Snacks.notify.error("Failed to update .gitignore: " .. tostring(err), { title = "Git ignore" })
		return
	end
	out:write(prefix .. pattern .. "\n")
	out:close()

	Snacks.notify.info(("Added `%s` to .gitignore"):format(pattern), { title = "Git ignore" })
	picker:refresh()
end

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	opts = {
		bufdelete = { enabled = true },
		picker = {
			enabled = true,
			layout = {
				fullscreen = true
			},
			actions = {
				add_to_gitignore = add_to_gitignore,
			},
			sources = {
				git_status = {
					win = {
						input = {
							keys = {
								["<C-g>"] = { "add_to_gitignore", mode = { "n", "i" }, desc = "Add to .gitignore" },
							},
						},
						list = {
							keys = {
								["<C-g>"] = { "add_to_gitignore", mode = { "n", "x" }, desc = "Add to .gitignore" },
							},
						},
					},
				},
				git_diff = {
					win = {
						input = {
							keys = {
								["<C-g>"] = { "add_to_gitignore", mode = { "n", "i" }, desc = "Add to .gitignore" },
							},
						},
						list = {
							keys = {
								["<C-g>"] = { "add_to_gitignore", mode = { "n", "x" }, desc = "Add to .gitignore" },
							},
						},
					},
				},
			},
		},
	},
	keys = {
		{ "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
		{ "<leader><space>", function() Snacks.picker.files() end, desc = "Find Files" },
		{ "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
		{ "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep" },
		{ "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
		{ "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff" },
	},
}

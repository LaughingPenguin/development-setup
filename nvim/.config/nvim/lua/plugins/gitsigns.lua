local function close_gitsigns_diff()
	local buf = vim.api.nvim_get_current_buf()
	local name = vim.api.nvim_buf_get_name(buf)
	local relpath

	if name:match("^gitsigns://") then
		relpath = name:match(":([^:]+)$")
	else
		local ok, cache = pcall(require, "gitsigns.cache")
		local bcache = ok and cache.cache[buf] or nil
		relpath = bcache and bcache.git_obj.relpath or nil
	end

	if not relpath then
		vim.notify("No Gitsigns diff for this buffer", vim.log.levels.WARN)
		return
	end

	local suffix = ":" .. relpath:gsub("([^%w])", "%%%1") .. "$"
	local revision_wins = {}
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local wbuf = vim.api.nvim_win_get_buf(win)
		local wname = vim.api.nvim_buf_get_name(wbuf)
		if wname:match("^gitsigns://") and wname:match(suffix) then
			revision_wins[#revision_wins + 1] = win
		end
	end

	for _, win in ipairs(revision_wins) do
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, false)
		end
	end

	local ok, cache = pcall(require, "gitsigns.cache")
	if not ok then
		return
	end
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local wbuf = vim.api.nvim_win_get_buf(win)
		local bcache = cache.cache[wbuf]
		if bcache and bcache.git_obj.relpath == relpath and vim.wo[win].diff then
			vim.api.nvim_win_call(win, function()
				vim.cmd("diffoff!")
			end)
		end
	end
end

return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	keys = {
		{ "]c", function() require("gitsigns").next_hunk() end, desc = "Next hunk" },
		{ "[c", function() require("gitsigns").prev_hunk() end, desc = "Previous hunk" },
		{ "<leader>hr", function() require("gitsigns").reset_hunk() end, desc = "Reset hunk" },
		{
			"<leader>dv",
			function()
				require("gitsigns").diffthis()
				vim.schedule(function()
					vim.cmd("windo normal! zR")
				end)
			end,
			desc = "Diff this file (unfold)",
		},
		{
			"<leader>dc",
			close_gitsigns_diff,
			desc = "Close current file diff",
		},
	},
}

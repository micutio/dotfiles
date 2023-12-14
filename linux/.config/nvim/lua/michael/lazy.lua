local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	--
	-- Color Themes   
	--
	{ 'rose-pine/neovim', name = 'rose-pine' },
    { "savq/melange-nvim", name = 'melange' },
    { "markvincze/panda-vim", name = 'panda'},
    { "NLKNguyen/papercolor-theme", name = 'papercolor' },
	--
	-- Plugins
	--
	{
		'nvim-telescope/telescope.nvim',
		branch = '0.1.x',
		dependencies = { 'nvim-lua/plenary.nvim' }
	},
	{
		"kevinhwang91/nvim-ufo",
		dependencies = 'kevinhwang91/promise-async',
		event = "BufRead",
	},
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate',
		config = function()
			require('ufo').setup({
				provider_selector = function(bufnr, filetype, buftype)
					return { 'treesitter', 'indent' }
				end
			})
		end,
	},
	{
		'nvim-lualine/lualine.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons', opt = true }
	},
	{
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v2.x',
		dependencies = {
			-- LSP Support
			{ 'neovim/nvim-lspconfig' }, -- Required
			{
				-- Optional
				'williamboman/mason.nvim',
				build = function()
					pcall(vim.cmd, 'MasonUpdate')
				end,
			},
			{ 'williamboman/mason-lspconfig.nvim' }, -- Optional
			-- Autocompletion
			{ 'hrsh7th/nvim-cmp' },     -- Required
			{ 'hrsh7th/cmp-nvim-lsp' }, -- Required
			{ 'L3MON4D3/LuaSnip' },     -- Required
		}
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
			"3rd/image.nvim",
		}
	},
	{ "sindrets/diffview.nvim"}
})

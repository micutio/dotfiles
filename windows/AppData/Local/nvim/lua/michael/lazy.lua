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
    { 'rose-pine/neovim',           name = 'rose-pine' },
    { 'savq/melange-nvim',          name = 'melange' },
    { 'markvincze/panda-vim',       name = 'panda' },
    { 'NLKNguyen/papercolor-theme', name = 'papercolor' },
    { 'p00f/alabaster.nvim',        name = 'alabaster' },
    {
        "zenbones-theme/zenbones.nvim",
        -- Optionally install Lush. Allows for more configuration or extending the colorscheme
        -- If you don't want to install lush, make sure to set g:zenbones_compat = 1
        -- In Vim, compat mode is turned on as Lush only works in Neovim.
        dependencies = "rktjmp/lush.nvim",
        lazy = false,
        priority = 1000,
        -- you can set set configuration options here
        -- config = function()
        --     vim.g.zenbones_darken_comments = 45
        --     vim.cmd.colorscheme('zenbones')
        -- end
    },
    --
    -- Plugins
    --
    {
        'nvim-telescope/telescope.nvim',
        branch = 'master',
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
    },
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons', opt = true }
    },
    {
        "Hoffs/omnisharp-extended-lsp.nvim", lazy = true
    },
    -- LSP (native vim.lsp.config / vim.lsp.enable; no lsp-zero)
    { 'neovim/nvim-lspconfig' },
    {
        'williamboman/mason.nvim',
        build = function()
            pcall(vim.cmd, 'MasonUpdate')
        end,
    },
    { 'williamboman/mason-lspconfig.nvim' },
    -- Autocompletion
    { 'hrsh7th/nvim-cmp' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'L3MON4D3/LuaSnip' },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
            -- "3rd/image.nvim",
            "folke/snacks.nvim"
        }
    },
    { "sindrets/diffview.nvim" },
    {
        "ray-x/lsp_signature.nvim"
    },
    {
        'MeanderingProgrammer/render-markdown.nvim',
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },            -- if you use the mini.nvim suite
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {},
        ft = { 'markdown', 'telekasten', 'rmd' },
    },
    {
        "nvim-flutter/flutter-tools.nvim",
        lazy = false,
        dependencies = {
            "nvim-lua/plenary.nvim",
            "stevearc/dressing.nvim", -- Optional: for better UI prompts
        },
        config = function()
            require("flutter-tools").setup({
                lsp = {
                    color_render = true, -- Previews colors in the editor
                    settings = {
                        showTodos = true,
                        completeFunctionCalls = true,
                    },
                },
                -- You can disable Flutter-specific UI if you want "Pure Dart" vibes
                debugger = { enabled = true },
            })
        end,
    },
    {
        "sphamba/smear-cursor.nvim",
        opts = {
            -- Smear cursor when switching buffers or windows.
            smear_between_buffers = true,

            -- Smear cursor when moving within line or to neighbor lines.
            -- Use `min_horizontal_distance_smear` and `min_vertical_distance_smear` for finer control
            smear_between_neighbor_lines = true,

            -- Draw the smear in buffer space instead of screen space when scrolling
            scroll_buffer_space = true,

            -- Set to `true` if your font supports legacy computing symbols (block unicode symbols).
            -- Smears and particles will look a lot less blocky.
            legacy_computing_symbols_support = false,

            -- Smear cursor in insert mode.
            -- See also `vertical_bar_cursor_insert_mode` and `distance_stop_animating_vertical_bar`.
            smear_insert_mode = true,
            stiffness = 0.8,                      -- 0.6      [0, 1]
            trailing_stiffness = 0.6,             -- 0.45     [0, 1]
            stiffness_insert_mode = 0.7,          -- 0.5      [0, 1]
            trailing_stiffness_insert_mode = 0.7, -- 0.5      [0, 1]
            damping = 0.95,                       -- 0.85     [0, 1]
            damping_insert_mode = 0.95,           -- 0.9      [0, 1]
            distance_stop_animating = 0.5,        -- 0.1      > 0
        }
    }
})

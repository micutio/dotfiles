-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'


    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.x',
        requires = { { 'nvim-lua/plenary.nvim' } }
    }

    use { 'rose-pine/neovim', as = 'rose-pine' }

    use { 'Mofiqul/adwaita.nvim', as = 'adwaita' }

    use { 'nyoom-engineering/oxocarbon.nvim', as = 'oxocarbon' }

    use { "savq/melange-nvim", as = 'melange' }
    
    use { "markvincze/panda-vim", as = 'panda'}
    
    use {
        'olivercederborg/poimandres.nvim',
        config = function()
            require('poimandres').setup {
                -- leave this setup function empty for default config
                -- or refer to the configuration section
                -- for configuration options
            }
        end
    }

    use { "EdenEast/nightfox.nvim",
        config = function()
            require('nightfox').setup{
                transparent = true,
                dim_inactive = true,
                styles = {
                    comments = "italic",
                    -- conditionals = "NONE",
                    constants = "standout",
                    -- functions = "NONE",
                    -- keywords = "NONE",
                    -- numbers = "NONE",
                    -- operators = "NONE",
                    -- strings = "NONE",
                    -- types = "NONE",
                    -- variables = "NONE",
                }
            }
        end
}

    use { 'kevinhwang91/nvim-ufo', requires = 'kevinhwang91/promise-async' }

    use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })
    require('ufo').setup({
        provider_selector = function(bufnr, filetype, buftype)
            return { 'treesitter', 'indent' }
        end
    })

    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'nvim-tree/nvim-web-devicons', opt = true }
    }

    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        requires = {
            -- LSP Support
            { 'neovim/nvim-lspconfig' }, -- Required
            {
                -- Optional
                'williamboman/mason.nvim',
                run = function()
                    pcall(vim.cmd, 'MasonUpdate')
                end,
            },
            { 'williamboman/mason-lspconfig.nvim' }, -- Optional

            -- Autocompletion
            { 'hrsh7th/nvim-cmp' },     -- Required
            { 'hrsh7th/cmp-nvim-lsp' }, -- Required
            { 'L3MON4D3/LuaSnip' },     -- Required
        }
    }

    use {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v2.x",
        requires = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
        }
    }
end)

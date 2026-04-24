-- Native Neovim LSP (vim.lsp.config / vim.lsp.enable). No lsp-zero, no require('lspconfig').

local capabilities = vim.tbl_deep_extend('force',
    vim.lsp.protocol.make_client_capabilities(),
    require('cmp_nvim_lsp').default_capabilities()
)

-- Global defaults for all LSP configs
vim.lsp.config('*', { capabilities = capabilities })

-- Per-server overrides
vim.lsp.config('lua_ls', {
    settings = {
        Lua = {
            diagnostics = { globals = { 'vim' } },
        },
    },
})

vim.lsp.config('omnisharp', {
    handlers = {
        ['textDocument/definition'] = require('omnisharp_extended').handler,
    },
    keys = {
        {
            'gd',
            require('omnisharp_extended').telescope_lsp_definitions(),
            desc = 'Goto Definition',
        },
    },
    enable_roslyn_analyzers = true,
    organize_imports_on_format = true,
    enable_import_completion = true,
})

vim.lsp.config('powershell_es', {
    filetypes = { 'ps1', 'psm1', 'psd1' },
    cmd = {
        'pwsh', '-NoLogo', '-NoProfile', '-Command',
        '~/AppData/Local/nvim-data/mason/packages/powershell-editor-services/PowerShellEditorServices/Start-EditorServices.ps1',
    },
    settings = { powershell = { codeFormatting = { Preset = 'OTBS' } } },
    init_options = {
        enableProfileLoading = false,
    },
})

vim.lsp.config('rust_analyzer', {
    settings = {
        ['rust-analyzer'] = {
            checkOnSave = {
                allFeatures = true,
                overrideCommand = {
                    'cargo', 'clippy', '--workspace', '--message-format=json',
                    '--all-targets', '--all-features',
                },
            },
        },
    },
})

-- LspAttach: keymaps + lsp_signature.on_attach(ev.buf)
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local bufnr = ev.buf
        local opts = { buffer = bufnr, remap = false }
        local client = vim.lsp.get_client_by_id(ev.data.client_id)

        -- omnisharp uses telescope for gd via vim.lsp.config keys; only set gd for others
        if not (client and client.name == 'omnisharp') then
            vim.keymap.set('n', 'gd', function() vim.lsp.buf.definition() end, opts)
        end
        vim.keymap.set('n', 'K', function() vim.lsp.buf.hover() end, opts)
        vim.keymap.set('n', '<leader>vws', function() vim.lsp.buf.workspace_symbol() end, opts)
        vim.keymap.set('n', '<leader>vd', function() vim.diagnostic.open_float() end, opts)
        vim.keymap.set('n', '[d', function() vim.diagnostic.goto_next() end, opts)
        vim.keymap.set('n', ']d', function() vim.diagnostic.goto_prev() end, opts)
        vim.keymap.set('n', '<leader>vca', function() vim.lsp.buf.code_action() end, opts)
        vim.keymap.set('n', '<leader>vrr', function() vim.lsp.buf.references() end, opts)
        vim.keymap.set('n', '<leader>vrn', function() vim.lsp.buf.rename() end, opts)
        vim.keymap.set('i', '<C-h>', function() vim.lsp.buf.signature_help() end, opts)

        require('lsp_signature').on_attach(_G.lsp_signature_cfg or {}, bufnr)
    end,
})

-- Mason: install LSP servers and tools
require('mason').setup()
require('mason-lspconfig').setup({
    ensure_installed = { 'lua_ls', 'omnisharp', 'powershell_es', 'rust_analyzer' },
    automatic_installation = true,
})

-- Diagnostics
vim.diagnostic.config({
    virtual_text = true,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = 'E',
            [vim.diagnostic.severity.WARN] = 'W',
            [vim.diagnostic.severity.HINT] = 'H',
            [vim.diagnostic.severity.INFO] = 'I',
        },
    },
})

-- nvim-cmp
local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }

cmp.setup({
    sources = {
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    },
    mapping = {
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm({ select = false }),
    },
})

-- Dart project navigation
-- vim.lsp.enable("dartls")

-- LuaSnip (snippet expand for cmp)
require('luasnip.loaders.from_vscode').lazy_load()

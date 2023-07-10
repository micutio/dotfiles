local function pickColorFromGSettings(lightTheme, darkTheme)
    local handle = io.popen("gsettings get org.gnome.desktop.interface color-scheme")
    local result = handle:read("*a")

    if string.find(result, "prefer-dark", 1, true) == nil then
        vim.opt.bg = 'light'
        vim.cmd.colorscheme(lightTheme)
    else
        vim.opt.bg = 'dark'
        vim.cmd.colorscheme(darkTheme)
    end

    handle:close()
end


function ColorMyPencils(lightTheme, darkTheme)
    lightTheme = lightTheme or "default"
    darkTheme = darkTheme or lightTheme
    pickColorFromGSettings(lightTheme, darkTheme)

    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
    vim.api.nvim_set_hl(0, "NeoTreeNormal", {bg= "none"})
    vim.api.nvim_set_hl(0, "NeoTreeNormalNC", {bg= "none"})
end

ColorMyPencils("rose-pine-dawn", "rose-pine-moon")

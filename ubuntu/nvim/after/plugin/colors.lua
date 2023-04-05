
function checkGsettings()
    local handle = io.popen("gsettings get org.gnome.desktop.interface color-scheme")
    local result = handle:read("*a")
   
    if string.find(result, "prefer-dark", 1, true) == nil then
        vim.opt.bg = 'light'
    else
        vim.opt.bg = 'dark'
    end

    handle:close()
end


function ColorMyPencils(color)
	color = color or "rose-pine"
	vim.cmd.colorscheme(color)
    checkGsettings()

	vim.api.nvim_set_hl(0, "Normal", {bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", {bg = "none" })
end

ColorMyPencils()
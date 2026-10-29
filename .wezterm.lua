-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration
local config = wezterm.config_builder()

-- Set platform-dependent default shell
if wezterm.target_triple:find('windows') then
    config.default_prog = { 'pwsh.exe' }
elseif wezterm.target_triple:find('linux') then
    config.default_prog = { 'zsh' }
elseif wezterm.target_triple:find('apple') then
    config.default_prog = { 'zsh' }
end

--config.color_scheme = 'rose-pine-moon'
config.color_scheme = 'Rosé Pine Moon (Gogh)'

config.font = wezterm.font('IosevkaTerm Nerd Font Mono', { weight = 'Medium' })
config.font_size = 11.0

-- Key Bindings
config.keys = {
    -- Close current pane (with a confirmation prompt)
    {
        key = 'w',
        mods = 'CTRL|SHIFT',
        action = wezterm.action.CloseCurrentPane { confirm = true },
    },
    -- Jump to tabs 1 through 9 using Ctrl + [1-9]
    { key = '1', mods = 'CTRL', action = wezterm.action.ActivateTab(0) },
    { key = '2', mods = 'CTRL', action = wezterm.action.ActivateTab(1) },
    { key = '3', mods = 'CTRL', action = wezterm.action.ActivateTab(2) },
    { key = '4', mods = 'CTRL', action = wezterm.action.ActivateTab(3) },
    { key = '5', mods = 'CTRL', action = wezterm.action.ActivateTab(4) },
    { key = '6', mods = 'CTRL', action = wezterm.action.ActivateTab(5) },
    { key = '7', mods = 'CTRL', action = wezterm.action.ActivateTab(6) },
    { key = '8', mods = 'CTRL', action = wezterm.action.ActivateTab(7) },
    { key = '9', mods = 'CTRL', action = wezterm.action.ActivateTab(-1) },
}

-- Tabs
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 32

-- Powerline symbols for rounded pill caps
local LEFT_CAP = ''
local RIGHT_CAP = ''

-- CACHE the scheme once at startup instead of inside the hover event
local scheme = wezterm.color.get_builtin_schemes()[config.color_scheme]
local bar_bg = scheme.tab_bar and scheme.tab_bar.background or scheme.background
local active_bg = scheme.ansi[5]
local active_fg = scheme.background
local inactive_bg = scheme.brights and scheme.brights[1] or '#333333'
local inactive_fg = scheme.foreground
local hover_bg = scheme.ansi[7]
local hover_fg = scheme.background

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    local pill_bg = inactive_bg
    local pill_fg = inactive_fg

    if tab.is_active then
        pill_bg = active_bg
        pill_fg = active_fg
    elseif hover then
        pill_bg = hover_bg
        pill_fg = hover_fg
    end

    -- Truncate title cleanly to fit within the max_width constraint (minus space for borders/indexes)
    local title = tab.active_pane.title
    local max = max_width - 6 -- accounting for padding, index, and caps
    if max < 5 then max = 5 end
    if #title > max then
        title = wezterm.truncate_right(title, max)
    end
    if tab.tab_title and #tab.tab_title > 0 then
        title = tab.tab_title
    end

    -- Construct pill shape using theme colors
    return {
        { Background = { Color = bar_bg } }, { Foreground = { Color = pill_bg } }, { Text = LEFT_CAP },
        { Background = { Color = pill_bg } }, { Foreground = { Color = pill_fg } }, { Text = ' ' .. (tab.tab_index + 1) .. ': ' .. title .. ' ' },
        { Background = { Color = bar_bg } }, { Foreground = { Color = pill_bg } }, { Text = RIGHT_CAP },
        { Background = { Color = bar_bg } }, { Text = ' ' },
    }
end)

return config

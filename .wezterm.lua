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
config.window_padding = {
    left = 5,
    right = 5,
    top = 5,
    bottom = 0,
}

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
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true
config.tab_max_width = 32
config.show_new_tab_button_in_tab_bar = false

-- Powerline symbols for rounded pill caps
local LEFT_CAP = ''
local RIGHT_CAP = ''

-- Cache the scheme once at startup instead of inside the hover event
local scheme = wezterm.color.get_builtin_schemes()[config.color_scheme]
local bar_bg = scheme.tab_bar and scheme.tab_bar.background or scheme.background
local active_bg = scheme.ansi[5]
local active_fg = scheme.background
local inactive_bg = scheme.brights and scheme.brights[1] or '#333333'
local inactive_fg = scheme.foreground
local hover_bg = scheme.ansi[7]
local hover_fg = scheme.background

-- Ensure the entire retro tab bar row (including empty space to the right of tabs) uses bar_bg
config.colors = {
    tab_bar = {
        background = bar_bg,
    },
}

local function get_tab_text(index, title, max_width)
    local prefix = ' ' .. (index + 1) .. ': '
    local suffix = ' '
    -- Reserve 3 cells for LEFT_CAP, RIGHT_CAP, and trailing space separator
    local available = (max_width or config.tab_max_width) - wezterm.column_width(prefix) - wezterm.column_width(suffix) -
        3
    if available < 5 then available = 5 end
    if wezterm.column_width(title) > available then
        title = wezterm.truncate_right(title, available)
    end
    return prefix .. title .. suffix
end

wezterm.on('update-status', function(window, _)
    local mux_win = window:mux_window()
    local active_tab = window:active_tab()
    if not mux_win or not active_tab then
        return
    end

    local cols = active_tab:get_size().cols
    local tabs = mux_win:tabs_with_info()

    local total_tabs_width = 0
    for _, item in ipairs(tabs) do
        local title = item.tab:get_title()
        if not title or #title == 0 then
            local active_pane = item.tab:active_pane()
            title = active_pane and active_pane:get_title() or ''
        end
        local tab_text = get_tab_text(item.index, title, config.tab_max_width)
        total_tabs_width = total_tabs_width + wezterm.column_width(tab_text) + 3
    end

    -- Subtract 1 so centering is based on the visible pills (excluding the final trailing space)
    local visible_width = math.max(0, total_tabs_width - 1)
    local left_padding = math.max(0, math.floor((cols - visible_width) / 2))
    local right_padding = math.max(0, cols - left_padding - total_tabs_width)

    window:set_left_status(wezterm.format({
        { Background = { Color = bar_bg } },
        { Text = string.rep(' ', left_padding) },
    }))
    window:set_right_status(wezterm.format({
        { Background = { Color = bar_bg } },
        { Text = string.rep(' ', right_padding) },
    }))
end)

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

    local tab_title = (tab.tab_title and #tab.tab_title > 0) and tab.tab_title or tab.active_pane.title
    local tab_text = get_tab_text(tab.tab_index, tab_title, max_width)

    -- Construct pill shape using theme colors
    return {
        { Background = { Color = bar_bg } }, { Foreground = { Color = pill_bg } }, { Text = LEFT_CAP },
        { Background = { Color = pill_bg } }, { Foreground = { Color = pill_fg } }, { Text = tab_text },
        { Background = { Color = bar_bg } }, { Foreground = { Color = pill_bg } }, { Text = RIGHT_CAP },
        { Background = { Color = bar_bg } }, { Text = ' ' },
    }
end)

-- PLUGIN SECTION
wezterm.plugin.require("https://gitlab.com/xarvex/presentation.wez").apply_to_config(config)
--

return config

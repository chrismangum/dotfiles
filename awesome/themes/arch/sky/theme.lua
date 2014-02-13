-------------------------------
--    "Sky" awesome theme    --
--  By Andrei "Garoth" Thorp --
-------------------------------
-- If you want SVGs and extras, get them from garoth.com/awesome/sky-theme

themesdir = "/home/chris/.config/awesome/themes/arch"
themedir = themesdir .. "/sky"

-- BASICS
theme = {}
theme.font          = "sans 8"

theme.bg_focus      = "#e2eeea"
theme.bg_normal     = "#729fcf"
theme.bg_urgent     = "#fce94f"
theme.bg_minimize   = "#0067ce"

theme.fg_normal     = "#2e3436"
theme.fg_focus      = "#2e3436"
theme.fg_urgent     = "#2e3436"
theme.fg_minimize   = "#2e3436"

theme.border_width  = "2"
theme.border_normal = "#dae3e0"
theme.border_focus  = "#729fcf"
theme.border_marked = "#eeeeec"

-- IMAGES
theme.layout_fairh           = themedir .. "/layouts/fairh.png"
theme.layout_fairv           = themedir .. "/layouts/fairv.png"
theme.layout_floating        = themedir .. "/layouts/floating.png"
theme.layout_magnifier       = themedir .. "/layouts/magnifier.png"
theme.layout_max             = themedir .. "/layouts/max.png"
theme.layout_fullscreen      = themedir .. "/layouts/fullscreen.png"
theme.layout_tilebottom      = themedir .. "/layouts/tilebottom.png"
theme.layout_tileleft        = themedir .. "/layouts/tileleft.png"
theme.layout_tile            = themedir .. "/layouts/tile.png"
theme.layout_tiletop         = themedir .. "/layouts/tiletop.png"
theme.layout_spiral          = themedir .. "/layouts/spiral.png"
theme.layout_dwindle         = themedir .. "/layouts/dwindle.png"

theme.awesome_icon           = themedir .. "/awesome-icon.png"
theme.tasklist_floating_icon = themedir .. "/layouts/floating.png"

-- from default for now...
theme.menu_submenu_icon     = themesdir .. "/default/submenu.png"
theme.taglist_squares_sel   = themesdir .. "/default/taglist/squarefw.png"
theme.taglist_squares_unsel = themesdir .. "/default/taglist/squarew.png"

-- MISC
theme.wallpaper             = themedir .. "/sky-background.png"
theme.taglist_squares       = "true"
theme.titlebar_close_button = "true"
theme.menu_height           = 15
theme.menu_width            = 100

-- Define the image to load
theme.titlebar_close_button_normal = themesdir .. "/default/titlebar/close_normal.png"
theme.titlebar_close_button_focus = themesdir .. "/default/titlebar/close_focus.png"

theme.titlebar_ontop_button_normal_inactive = themesdir .. "/default/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive = themesdir .. "/default/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = themesdir .. "/default/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active = themesdir .. "/default/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = themesdir .. "/default/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive = themesdir .. "/default/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = themesdir .. "/default/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active = themesdir .. "/default/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = themesdir .. "/default/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive = themesdir .. "/default/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = themesdir .. "/default/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active = themesdir .. "/default/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = themesdir .. "/default/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive = themesdir .. "/default/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = themesdir .. "/default/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active = themesdir .. "/default/titlebar/maximized_focus_active.png"

return theme
-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80

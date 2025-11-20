local Util = require("ethereal.utils")

local M = {}

---@class Palette
local default_palette = {
	bg = "#060B1E",
	bg_dark = "#060B1E",
	bg_dark1 = "#060B1E",
	bg_highlight = "#060B1E",

	-- Ethereal accent colors
	blue = "#7d82d9",
	blue0 = "#264f78",
	blue1 = "#7d82d9",
	blue2 = "#7d82d9",
	blue5 = "#a3bfd1",
	blue6 = "#b4f9f8",
	blue7 = "#1e3a5f",

	comment = "#6d7db6",
	cyan = "#a3bfd1",

	dark3 = "#6d7db6",
	dark5 = "#F99957",

	fg = "#ffcead",
	fg_dark = "#F99957",
	fg_gutter = "#6d7db6", -- Same as base03/comment for visibility

	green = "#92a593",
	green1 = "#92a593",
	green2 = "#92a593",

	magenta = "#c89dc1",
	magenta2 = "#8e93de",

	orange = "#faaaa9",
	purple = "#c89dc1",

	red = "#ED5B5A",
	red1 = "#ED5B5A",

	teal = "#a3bfd1",
	terminal_black = "#6d7db6",

	yellow = "#E9BB4F",

	-- Git colors will be calculated from the palette colors above
	git = {},

	-- Base16 compatibility (deprecated, kept for backward compatibility)
	base00 = "#060B1E",
	base01 = "#6d7db6",
	base02 = "#060B1E",
	base03 = "#6d7db6",
	base04 = "#F99957",
	base05 = "#ffcead",
	base06 = "#ffcead",
	base07 = "#F99957",
	base08 = "#ED5B5A",
	base09 = "#faaaa9",
	base0A = "#E9BB4F",
	base0B = "#92a593",
	base0C = "#a3bfd1",
	base0D = "#7d82d9",
	base0E = "#c89dc1",
	base0F = "#f7dc9c",
}

---@param opts? ethereal.Config
function M.setup(opts)
	opts = require("ethereal.config").extend(opts)

	-- Color Palette
	---@class ColorScheme: Palette
	local colors = vim.deepcopy(default_palette)

	if opts.colors and next(opts.colors) then
		colors = vim.tbl_deep_extend("force", colors, opts.colors)

		-- Map base16 colors to semantic names AND all variants if base16 colors were provided
		if opts.colors.base00 then
			colors.bg = opts.colors.base00
			colors.bg_dark = opts.colors.base00
			colors.bg_dark1 = opts.colors.base00
		end
		if opts.colors.base01 then
			colors.terminal_black = opts.colors.base01
		end
		if opts.colors.base02 then
			colors.bg_highlight = opts.colors.base02
		end
		if opts.colors.base03 then
			colors.comment = opts.colors.base03
			colors.dark3 = opts.colors.base03
			colors.fg_gutter = opts.colors.base03 -- Line numbers should be visible like comments
		end
		if opts.colors.base04 then
			colors.dark5 = opts.colors.base04
			colors.fg_dark = opts.colors.base04
		end
		if opts.colors.base05 then
			colors.fg = opts.colors.base05
		end
		if opts.colors.base08 then
			colors.red = opts.colors.base08
			colors.red1 = opts.colors.base08
		end
		if opts.colors.base09 then
			colors.orange = opts.colors.base09
		end
		if opts.colors.base0A then
			colors.yellow = opts.colors.base0A
		end
		if opts.colors.base0B then
			colors.green = opts.colors.base0B
			colors.green1 = opts.colors.base0B
			colors.green2 = opts.colors.base0B
		end
		if opts.colors.base0C then
			colors.cyan = opts.colors.base0C
			colors.teal = opts.colors.base0C
			colors.blue5 = opts.colors.base0C
			colors.blue6 = opts.colors.base0C
		end
		if opts.colors.base0D then
			colors.blue = opts.colors.base0D
			colors.blue1 = opts.colors.base0D
			colors.blue2 = opts.colors.base0D
		end
		if opts.colors.base0E then
			colors.purple = opts.colors.base0E
			colors.magenta = opts.colors.base0E
			colors.magenta2 = opts.colors.base0E
		end
		if opts.colors.base0F then
			-- Brown/deprecated color - no direct mapping needed
		end
	end

	Util.bg = colors.bg or colors.base00
	Util.fg = colors.fg or colors.base05

	colors.none = "NONE"

	-- Always update git colors to use the palette colors (either default or injected)
	-- This ensures git colors are derived from the theme colors
	colors.git.add = colors.green2 or colors.green
	colors.git.delete = colors.red1 or colors.red
	colors.git.change = colors.orange or colors.yellow

	-- Diff colors using tokyonight approach
	colors.diff = {
		add = Util.blend_bg(colors.green2 or colors.green, 0.25),
		delete = Util.blend_bg(colors.red1 or colors.red, 0.25),
		change = Util.blend_bg(colors.blue7 or colors.blue, 0.15),
		text = colors.blue7 or colors.blue,
	}

	colors.git.ignore = colors.dark3
	colors.black = Util.blend_bg(colors.bg, 0.8, colors.bg)
	colors.border_highlight = Util.blend_bg(colors.blue1, 0.8)
	colors.border = colors.black

	-- Popups and statusline always get a dark background
	colors.bg_popup = colors.bg_dark
	colors.bg_statusline = colors.bg_dark

	-- Sidebar and Floats are configurable
	colors.bg_sidebar = opts.styles.sidebars == "transparent" and colors.none
		or opts.styles.sidebars == "dark" and colors.bg_dark
		or colors.bg

	colors.bg_float = opts.styles.floats == "transparent" and colors.none
		or opts.styles.floats == "dark" and colors.bg_dark
		or colors.bg

	colors.bg_visual = Util.blend_bg(colors.blue0, 0.4)
	colors.bg_search = colors.blue0
	colors.fg_sidebar = colors.fg
	colors.fg_float = colors.fg

	colors.error = colors.red1
	colors.todo = colors.blue
	colors.warning = colors.yellow
	colors.info = colors.blue2
	colors.hint = colors.teal

	-- Create blended colors for subtle highlights
	colors.subtle_bg = Util.blend_bg(colors.fg, 0.10)
	colors.cursorline_bg = Util.blend_bg(colors.fg, 0.20)
	colors.selection_bg = Util.blend_bg(colors.fg, 0.25)
	colors.float_bg = Util.blend_bg(colors.fg, 0.12)

	colors.rainbow = {
		colors.blue,
		colors.yellow,
		colors.green,
		colors.teal,
		colors.magenta,
		colors.purple,
		colors.orange,
		colors.red,
	}

	-- Terminal colors
	colors.terminal = {
		black = colors.black,
		black_bright = colors.terminal_black,
		red = colors.red,
		red_bright = colors.red,
		green = colors.green,
		green_bright = colors.green,
		yellow = colors.yellow,
		yellow_bright = colors.yellow,
		blue = colors.blue,
		blue_bright = colors.blue,
		magenta = colors.magenta,
		magenta_bright = colors.magenta,
		cyan = colors.cyan,
		cyan_bright = colors.cyan,
		white = colors.fg_dark,
		white_bright = colors.fg,
	}

	-- Call user's on_colors callback for further customization
	opts.on_colors(colors)

	return colors, opts
end

return M

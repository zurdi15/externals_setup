local awful = require('awful')
local gears = require('gears')
local beautiful = require('beautiful')

local icons = require('theme.icons')

local tags = {
	{
		icon = icons.terminal,
		type = 'terminal',
		defaultApp = 'konsole',
		screen = 1
	},
	{
		icon = icons.chrome,
		type = 'chrome',
		defaultApp = 'google-chrome-stable',
		screen = 1
	},
	{
		icon = icons.text_editor,
		type = 'code',
		defaultApp = 'subl',
		screen = 1
	},
	{
		icon = icons.file_manager,
		type = 'files',
		defaultApp = 'nemo',
		screen = 1
	},
	{
		icon = icons.sandbox,
		type = 'any',
		defaultApp = '',
		screen = 1
	}
}


tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
		awful.layout.suit.spiral.dwindle,
		awful.layout.suit.tile,
		awful.layout.suit.max
    })
end)


screen.connect_signal("request::desktop_decoration", function(s)
	for i, tag in pairs(tags) do
		awful.tag.add(
			i,
			{
				icon = tag.icon,
				icon_only = true,
				layout = awful.layout.suit.spiral.dwindle,
				gap_single_client = false,
				gap = beautiful.useless_gap,
				screen = s,
				defaultApp = tag.defaultApp,
				selected = i == 1
			}
		)
	end
end)


tag.connect_signal(
	'property::layout',
	function(t)
		local currentLayout = awful.tag.getproperty(t, 'layout')
		if (currentLayout == awful.layout.suit.max) then
			t.gap = 0
		else
			t.gap = beautiful.useless_gap
		end
	end
)

local awful = require('awful')
local gears = require('gears')
local ruled = require("ruled")
local beautiful = require('beautiful')

local client_keys = require('configuration.client.keys')
local client_buttons = require('configuration.client.buttons')

-- {{{ Rules
-- Rules to apply to new clients.
ruled.client.connect_signal("request::rules", function()
	-- All clients will match this rule.
	ruled.client.append_rule {
		id = "global",
		rule = { },
		properties = {
			focus = awful.client.focus.filter,
			raise = true,
			floating = false,
			maximized = false,
			above = false,
			below = false,
			ontop = false,
			sticky = false,
			maximized_horizontal = false,
			maximized_vertical = false,
			round_corners = true,
			keys = client_keys,
			buttons = client_buttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap+awful.placement.no_offscreen
		}
	}

	-- Dialogs
	ruled.client.append_rule {
		id = "dialog",
		rule_any = { 
			type = { "dialog" },
			class = { "Wicd-client.py", "calendar.google.com" },
		},
		properties = { 
			titlebars_enabled = true,
			floating = true,
			draw_backdrop = true,
			skip_decoration = true,
			shape = function(cr, width, height)
						gears.shape.rounded_rect(cr, width, height, beautiful.client_radius)
					end,
			placement = awful.placement.centered
		}
	}

	-- Modals
	ruled.client.append_rule {
		id = "dialog",
		rule_any = { 
			type = { "modal" },
		},
		properties = { 
			titlebars_enabled = true,
			floating = true,
			draw_backdrop = true,
			skip_decoration = true,
			shape = function(cr, width, height)
						gears.shape.rounded_rect(cr, width, height, beautiful.client_radius)
					end,
			placement = awful.placement.centered
		}
	}

	-- Utilities
	ruled.client.append_rule {
		id = "utility",
		rule_any = { 
			type = { "utility", "splash" }
		},
		properties = { 
			titlebars_enabled = false,
			floating = true,
			hide_titlebars = true,
			draw_backdrop = false,
			skip_decoration = true,
			placement = awful.placement.centered
		}
	}

	-- Splash
	ruled.client.append_rule {
		id = "splash",
		rule_any = { 
			type = { "splash" }
		},
		properties = { 
			titlebars_enabled = false,
			floating = true,
			hide_titlebars = true,
			draw_backdrop = false,
			skip_decoration = true,
			shape = function(cr, width, height)
						gears.shape.rounded_rect(cr, width, height, beautiful.client_radius)
					end,
			placement = awful.placement.centered
		}
	}

	-- Terminal emulators
	ruled.client.append_rule {
		id = "terminals",
		rule_any = { 
			class = { 
				"konsole"
			},
		},
		properties = {
			tag = '1',
			switchtotag = true,
			skip_decoration = true
		}
	}

	-- Browsers
	ruled.client.append_rule {
		id = "web_browsers",
		rule_any = { 
			class = {
				"chrome",
				"firefox",
			}
		},
		properties = { 
			tag = '2',
			switchtotag = true,
			skip_decoration = true
		}
	}

	-- Text editors
	ruled.client.append_rule {
		id = "text_editors",
		rule_any = { 
			class = {
				"Sublime_text",
			}
		},
		properties = { 
			tag = '3',
			switchtotag = true,
			skip_decoration = true
		}
	}

	-- File managers
	ruled.client.append_rule {
		id = "file_managers",
		rule_any = { 
			class = {
				"Nemo",
			}
		},
		properties = { 
			tag = '4',
			switchtotag = true,
			skip_decoration = true
		}
	}

	-- Any other
	ruled.client.append_rule {
		id = "any",
		rule_any = { 
			class = {
			}
		},
		properties = { 
			tag = '5',
			switchtotag = true,
			skip_decoration = true
		}
	}

	-- Hide titlebars
	ruled.client.append_rule {
		id = "hide_titlebars",
		rule_any = {
			class = {
				"feh",
				"Mugshot",
				"Pulseeffects"
			},
		},
		properties = { 
			skip_decoration = true,
			hide_titlebars = true,
			floating = true,
			ontop = true,
			placement = awful.placement.centered
		}
	}

	-- Instances
	ruled.client.append_rule {
		id = "instances",
		rule_any = {
			instance = {
				"file_progress",
				"Popup",
				"nm-connection-editor"
			},
		},
			properties = { 
			skip_decoration = true,
			round_corners = true,
			ontop = true,
			floating = true,
			draw_backdrop = false,
			focus = awful.client.focus.filter,
			raise = true,
			keys = client_keys,
			buttons = client_buttons,
			placement = awful.placement.centered
		}
	}
	
	-- Fullsreen
	ruled.client.append_rule {
		id = "fullscreen",
		rule_any = {
			class = {
				"SuperTuxKart"
			},
		},
		properties = { 
			skip_decoration = true,
			round_corners = false,
			ontop = true,
			floating = false,
			fullscreen = true,
			draw_backdrop = false,
			raise = true,
			keys = client_keys,
			buttons = client_buttons,
			placement = awful.placement.centered
		}
	}


end)


-- Normally we'd do this with a rule, but other apps like spotify and supertuxkart doesn't set its class or name
-- until after it starts up, so we need to catch that signal.

-- If the application is fullscreen in its settings, make sure to set `c.fullscreen = false` first
-- before moving to the desired tag or else the tag where the program spawn will cause panels to hide. 
-- After moving the program to specified tag you can set `c.fullscreen = true` now
-- See what I did in `SuperTuxKart`

client.connect_signal("property::class", function(c)
	if c.class == "Spotify" then
		-- Check if Spotify is already open
		local spotify = function (c)
			return ruled.client.match(c, { class = "Spotify" })
		end

		local spotify_count = 0
		for c in awful.client.iterate(spotify) do
			spotify_count = spotify_count + 1
		end

		-- If Spotify is already open, don't open a new instance
		if spotify_count > 1 then
			c:kill()

			-- Switch to previous instance
			for c in awful.client.iterate(spotify) do
				c:jump_to(false)
			end
		else

			-- Move the Spotify instance to "5" tag on this screen
			local t = awful.tag.find_by_name(awful.screen.focused(), "5")
			c:move_to_tag(t)
		end
	elseif c.class == "SuperTuxKart" then
		-- Disable fullscreen first
		c.fullscreen = false

		-- Check if SuperTuxKart is already open
		local stk = function (c)
			return ruled.client.match(c, { class = "SuperTuxKart" })
		end

		local stk_count = 0
		for c in awful.client.iterate(stk) do
			stk_count = stk_count + 1
		end

		-- If SuperTuxKart is already open, don't open a new instance
		if stk_count > 1 then
			c:kill()

			-- Switch to previous instance
			for c in awful.client.iterate(stk) do
				c:jump_to(false)
			end
		else

			-- Move the instance to specified tag tag on this screen
			local t = awful.tag.find_by_name(awful.screen.focused(), "6")
			c:move_to_tag(t)
			t:view_only()
			
			-- Enable fullscreeen again
			c.fullscreen = true
		end
	end
end)

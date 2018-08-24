name = 'FinderMod'
description = 'Highlights nearby containers that contain necessary items.\nJust hold item, or hover over ingredients in CraftMenu\n\nCompatible to Craft Pot mod. Hover over recipe ingredients to eg. find veggies'
author = 'modding,Serpens'
version = '1.13'
forumthread = ''
api_version = 6
api_version_dst = 10 -- correct api version added
priority = -2221 -- has to be this low to load after Craft Pot mod
dont_starve_compatible = true
reign_of_giants_compatible = true
shipwrecked_compatible = true
dst_compatible = true
all_clients_require_mod = true -- client_only_mod does not work =/
client_only_mod = false
server_filter_tags = {}

icon_atlas = 'atlas.xml'
icon       = 'icon.tex'

configuration_options =
{
	{
		name = "active",
		label = "Active?",
		hover = "Do you want to enable or disable highlighting?\nThis way also clients can disable highlighting if they want to.",
		options =	{
						{description = "Disabled", data = false}, -- to allow clients to disable highlighting
                        {description = "Enabled", data = true},
					},
		default = true,
	},
}

name = 'Findomizer'
description = 'Client Version of the famous Finder mode.Works by memorizing contents of open containers.\nHighlights nearby containers that contain necessary items.\n'
author = 'IvanX, Serpens, modding'
version = '0.01'
forumthread = ''
api_version = 6
api_version_dst = 10 -- correct api version added
priority = -2221 -- has to be this low to load after Craft Pot mod
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false
dst_compatible = true
--all_clients_require_mod = true
--client_only_mod = false
all_clients_require_mod = false
client_only_mod = true
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

main.register_mode("default", {
	full_name = "PvP Party",
	min_players = 1,
	drops = main.default_drops,
	starter_items = main.default_starter_items,
	drop_interval = main.default_drop_interval,
})

local function rand_mode()
	local online = #minetest.get_connected_players()
	local modes = {}

	for name, def in pairs(main.modes) do
		if online >= def.min_players then
			table.insert(modes, name)
		end
	end

	return(modes[math.random(1, #modes)])
end

local modestep = 0
minetest.register_globalstep(function(dtime)
	if modestep < main.mode_interval then
		modestep = modestep + dtime
	else
		modestep = 0
		main.start_mode(rand_mode())
	end
end)
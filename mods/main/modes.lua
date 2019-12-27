--[[ All mode settings

main.register_mode("modename", {
	full_name = "Mode Name", <required>
	min_players = 1, <required>
	drops = main.default_drops, <required>
	starter_items = main.default_starter_items, <required>
	drop_interval = main.default_drop_interval, <required>
	on_start = function(), <optional>
	on_end = function(), <optional>
	on_step = function(dtime), <optional>
	on_death = function(player, reason), <optional>
	on_respawn = function(player), <optional>
})

]]--

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

local modechangestep = 0
minetest.register_globalstep(function(dtime)
	if #minetest.get_connected_players() > 0 then
		if modechangestep < main.mode_interval then
			modechangestep = modechangestep + dtime
		else
			modechangestep = 0

			main.sethud_all("Changing mode...")
			minetest.after(3, function() main.start_mode(rand_mode()) end)
		end

		if vc_info.mode_running and main.current_mode.mode.on_step then
			main.current_mode.mode.on_step(dtime)
		end
	else
		vc_info.mode_running = false
	end
end)

minetest.register_on_dieplayer(function(player, reason)
	if vc_info.mode_running and main.current_mode.mode.on_death and main.playing[player:get_player_name()] then
		main.current_mode.mode.on_death(player, reason)
	end
end)

minetest.register_on_respawnplayer(function(player)
	if vc_info.mode_running and main.current_mode.mode.on_respawn and main.playing[player:get_player_name()] then
		main.current_mode.mode.on_respawn(player)
	end

	main.on_respawn(player)
end)

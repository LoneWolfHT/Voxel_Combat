--[[ All mode settings

main.register_mode("modename", {
	full_name = "Mode Name", <required>
	min_players = 1, <required>
	drops = main.default_drops, <required>
	starter_items = main.default_starter_items, <required>
	drop_interval = main.default_drop_interval, <required>
	pvp = <bool>, <default is false>
	on_start = function(), <optional>
	on_end = function(), <optional>
	on_step = function(dtime), <optional>
	on_death = function(player, reason), <optional>
	on_respawn = function(player), <optional>
})

]]--

main.register_mode("pvp_party", {
	full_name = "PvP Party",
	min_players = 2,
	pvp = true,
	drops = main.default_drops,
	starter_items = main.default_starter_items,
	drop_interval = main.default_drop_interval,
})

local z_s_modestep = 20 * 3
main.register_mode("zombie_survival", {
	full_name = "Zombie Survival",
	min_players = 1,
	drops = main.default_drops,
	starter_items = main.default_starter_items,
	on_step = function(dtime)
		z_s_modestep = z_s_modestep + dtime

		if z_s_modestep >= 20 then
			z_s_modestep = z_s_modestep - 20
		else
			return
		end

		local objects_in_area = minetest.get_objects_inside_radius(vector.new(), 25)
		local zombiecount = 0
		local sharkcount = 0
		local connected_players = #minetest.get_connected_players()

		for _, obj in pairs(objects_in_area) do
			if not obj:is_player() then
				local name = obj:get_luaentity().name

				if name == "zombiestrd:zombie" then
					zombiecount = zombiecount + 1
				elseif name == "zombiestrd:shark" then
					sharkcount = sharkcount + 1
				end
			end
		end

		local nodes_under_air = minetest.find_nodes_in_area_under_air(
			vector.new(-19, 0, -19),
			vector.new(19, 16, 19),
			"group:zombie_ground" -- See preregistered_edits
		)
		local water_nodes_in_area = minetest.find_nodes_in_area(
			vector.new(-19, 0, -19),
			vector.new(19, 16, 19),
			"group:water" -- group given to water liquid
		)

		if zombiecount < 4 + (connected_players * 3) and nodes_under_air and #nodes_under_air > 1 then
			local spawnpos = nodes_under_air[math.random(1, #nodes_under_air)]

			spawnpos.y = spawnpos.y + 2
			minetest.add_entity(spawnpos, "zombiestrd:zombie")
		end

		if sharkcount < 2 + (connected_players * 1) and water_nodes_in_area and #water_nodes_in_area > 4 then
			local spawnpos = water_nodes_in_area[math.random(1, #water_nodes_in_area)]

			spawnpos.y = spawnpos.y + 2
			minetest.add_entity(spawnpos, "zombiestrd:shark")
		end
	end,
})

function main.rand_mode()
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
			minetest.after(3, function() main.start_mode(main.rand_mode()) end)
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

	return true
end)

main = {
	modes = {},
	mode_interval = 60 * 10,
	default_drops = {
		default = "shooter_guns:ammo",
		["shooter_guns:pistol_loaded"] = 20,
		["shooter_guns:rifle_loaded"] = 36,
		["shooter_guns:machine_gun_loaded"] = 60,
		["shooter_guns:shotgun_loaded"] = 60,
		["vc_weapons:sword"] = 70,
	},
	default_starter_items = {"vc_weapons:knife", "shooter_guns:pistol_loaded", "shooter_guns:ammo 2"},
	default_drop_interval = 20
}

function main.register_mode(name, def)
	main.modes[name] = def
end

function main.start_mode(name)
	local map = maps.get_rand_map()

	if not map then
		minetest.log("error", "No maps to play on! Create one with /maps new")
		return
	end

	local mapdef = maps.load_map(map)
	main.current_mode = {
		name = name,
		mode = main.modes[name],
		itemspawns = mapdef.itemspawns,
		playerspawns = mapdef.playerspawns,
	}

	for _, p in ipairs(minetest.get_connected_players()) do
		if main.modes[name].starter_items and not minetest.check_player_privs(p, {map_maker = true}) then
			for k, item in ipairs(main.modes[name].starter_items) do
				p:get_inventory():add_item("main", item)
			end
		end

		p:set_pos(main.current_mode.playerspawns[math.random(1, #main.current_mode.playerspawns)])
	end

	minetest.chat_send_all(minetest.colorize("yellow", "[Voxel Combat] ").."Current mode: "..main.modes[name].full_name..
	". Current map (By "..mapdef.creator.."): "..mapdef.name)
end

--
--- Player join/leave/die/damage taken
--

minetest.register_on_joinplayer(function(p)
	p:set_hp(20, {type = "set_hp"})

	if #minetest.get_connected_players() == 1 then
		main.start_mode("default")
	else
		p:set_pos(main.current_mode.playerspawns[math.random(1, #main.current_mode.playerspawns)])
	end

	skybox.set(p, 6)
	local one, two, three = p:get_sky()
	p:set_sky(one, two, three, false)
end)

minetest.register_on_respawnplayer(function(p)
	p:set_pos(main.current_mode.playerspawns[math.random(1, #main.current_mode.playerspawns)])

	return true
end)

minetest.register_on_player_hpchange(function(_, hp_change, reason)
	if reason.type == "fall" then
		return 0
	else
		return hp_change
	end
end, true)

--
--- Misc
--

function minetest.item_drop() -- Prevent picking up/dropping items
	return
end

minetest.set_mapgen_setting("mg_name", "singlenode", true) -- Set mapgen to singlenode

dofile(minetest.get_modpath("main").."/modes.lua")
dofile(minetest.get_modpath("main").."/drops.lua")
dofile(minetest.get_modpath("main").."/inv.lua")
dofile(minetest.get_modpath("main").."/sprint.lua")
dofile(minetest.get_modpath("main").."/item_pickup.lua")
dofile(minetest.get_modpath("main").."/kill_fall.lua")
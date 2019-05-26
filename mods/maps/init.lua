local function S(txt)
	return txt
end

dofile(minetest.get_modpath("maps").."/nodes.lua")

maps = {}

maps.mappath = minetest.get_worldpath().."/maps/" -- minetest.get_modpath("maps").."/maps/"

local editing_map = false
local editing

minetest.register_privilege("map_maker", {
	description = S("Allows use of the map making commands/tools"),
	give_to_singleplayer = false,
	give_to_admin = true,
})

minetest.register_chatcommand("maps", {
	description = S("Maps command. Run /maps <h/help> for a list of subcommands"),
	privs = {map_maker = true},
	func = function(name, params)
		params = string.split(params, " ")

		if not params then return end

		if params[1] == "h" or params[1] == "help" then
			return true, "Options: help/h | new | edit <mapname> | save [mapname (Only needed for new maps])"
		end

		if params[1] == "new" then
			if not editing_map then
				return true, maps.new_map(name)
			else
				return false, "A map is already being edited!"
			end
		elseif params[1] == "edit" and params[2] then
			if not editing_map then
				return true, maps.edit_map(name, params[2])
			else
				return false, "A map is already being edited!"
			end
		elseif params[1] == "save" then
			return true, maps.save_map(name, params[2])
		else
			return false, "Options: help/h | new | edit <mapname> | save [mapname (Only needed for new maps])"
		end
	end
})

function maps.new_map(pname)
	local player = minetest.get_player_by_name(pname)
	local mpos = vector.new(0, 777, 0)

	editing_map = true

	minetest.emerge_area(vector.subtract(mpos, vector.new(20, 0, 20)), vector.add(mpos, vector.new(20, 16, 20)))
	minetest.place_schematic(mpos, minetest.get_modpath("maps").."/schems/base.mts", 0, {}, true,
		{place_center_x = true, place_center_y=false, place_center_z=true})

	player:set_pos(vector.new(0, 778, 0))

	return "Map container placed, build away!"
end

function maps.save_map(pname, mname)
	if not mname and editing then
		mname = editing
	end
	mname = mname:gsub(" ", "_")

	local path = maps.mappath..mname.."/"
	minetest.mkdir(path)
	local conf, error = io.open(path.."map.conf", "w")
	local startpos = vector.new(0, 777+8, 0)

	if not minetest.find_node_near(startpos, 20, "maps:spawnpoint", true) then
		return "You must place at least one player spawner first!"
	end

	if not conf then return error end
	if maps.map_exists(mname) and editing and editing ~= mname then
		return "There is already a map with this name!"
	end

	conf:write("name = <"..mname..">")
	conf:write("\ncreator = <"..pname..">")

	for finame, item in pairs({pspawns = "maps:spawnpoint", ispawns = "maps:itemspawner"}) do
		local pos = minetest.find_node_near(startpos, 20, item, true)
		local positions = {}

		while pos do
			local rpos = vector.new(pos.x, pos.y-777, pos.z)
			table.insert(positions, rpos)
			minetest.remove_node(pos)
			pos = minetest.find_node_near(startpos, 20, item, true)
		end

		if positions then
			conf:write("\n"..finame.." = <"..minetest.serialize(positions)..">")
		end
	end

	conf:close()

	local r = minetest.create_schematic(vector.new(-19, 778, -19), vector.new(19, 778+14, 19), {}, path.."map.mts", {})

	if r then
		maps.new_map(pname)

		editing_map = false
		editing = nil

		return "Saved map!"
	end

	return "Failed to create map schematic"
end

function maps.edit_map(pname, mname)
	local player = minetest.get_player_by_name(pname)
	local mpos = vector.new(0, 777, 0)
	local mpos_up = vector.new(0, 778, 0)

	if not maps.map_exists(mname) then return "No such map!" end

	editing_map = true
	editing = mname

	minetest.emerge_area(vector.subtract(mpos, vector.new(20, 0, 20)), vector.add(mpos, vector.new(20, 16, 20)))
	minetest.place_schematic(mpos, minetest.get_modpath("maps").."/schems/base.mts", 0, {}, true,
		{place_center_x = true, place_center_y=false, place_center_z=true})
	minetest.place_schematic(mpos_up, maps.mappath..mname.."/map.mts", 0, {}, true,
		{place_center_x = true, place_center_y=false, place_center_z=true})

	local conf, error = io.open(maps.mappath..mname.."/map.conf")

	if not conf then return error end

	local cfile = conf:read("*all")

	local playerspawns = minetest.deserialize(cfile:match("pspawns = <.->"):sub(12, -2))
	local itemspawns = minetest.deserialize(cfile:match("ispawns = <.->"):sub(12, -2))

	conf:close()

	while playerspawns and playerspawns[1] do
		playerspawns[1].y = playerspawns[1].y + 777
		minetest.set_node(playerspawns[1], {name = "maps:spawnpoint"})
		table.remove(playerspawns, 1)
	end

	while itemspawns and itemspawns[1] do
		itemspawns[1].y = itemspawns[1].y + 777
		minetest.set_node(itemspawns[1], {name = "maps:itemspawner"})
		table.remove(itemspawns, 1)
	end

	while minetest.get_node(mpos_up).name ~= "air" do
		mpos_up.y = mpos_up.y + 1
	end

	player:set_pos(mpos_up)

	return "Map placed, edit away!"
end

function maps.map_exists(name)
	for _, n in pairs(minetest.get_dir_list(minetest.get_worldpath().."/maps/", true)) do
		if n == name then
			return true
		end
	end

	return false
end

function maps.get_rand_map(name)
	local list = minetest.get_dir_list(minetest.get_worldpath().."/maps/", true)

	if not list or #list == 0 then return end

	return list[math.random(1, #list)]
end

function maps.load_map(name)
	local pos = vector.new(0, 0, 0)
	local conf, error = io.open(maps.mappath..name.."/map.conf")
	local mapdef = {}

	if not conf then return error end
	local cfile = conf:read("*all")

	mapdef.name = cfile:match("name = <.->"):sub(9, -2)
	mapdef.creator = cfile:match("creator = <.->"):sub(12, -2)
	mapdef.playerspawns = minetest.deserialize(cfile:match("pspawns = <.->"):sub(12, -2))
	mapdef.itemspawns = minetest.deserialize(cfile:match("ispawns = <.->"):sub(12, -2))

	conf:close()

	minetest.place_schematic(pos, maps.mappath..name.."/map.mts", 0, {}, true,
		{place_center_x = true, place_center_y=false, place_center_z=true})

	return mapdef
end

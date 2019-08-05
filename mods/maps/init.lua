local function S(txt)
	return txt
end

dofile(minetest.get_modpath("maps").."/nodes.lua")

maps = {}

maps.mappath = minetest.get_worldpath().."/maps/" -- minetest.get_modpath("maps").."/maps/"

local editors = {}
local editedmaps = 0

skybox.skies = {
	"DarkStormy",
	"CloudyLightRays",
	"FullMoon",
	"SunSet",
	"ThickCloudsWater",
	"TropicalSunnyDay",
}

minetest.register_privilege("map_maker", {
	description = S("Allows use of the map making commands/tools"),
	give_to_singleplayer = false,
	give_to_admin = true,
})

minetest.register_chatcommand("maps", {
	description = S("Maps command. Run /maps <h/help> for a list of subcommands"),
	privs = {map_maker = true},
	func = function(name, params)
		params = params:split(" ", false, 1)

		if not params then return end

		if params[1] == "h" or params[1] == "help" then
			return true, "Options: help/h | new | edit <mapname> | save"
		end

		if params[1] == "new" then
			if not editors[name] then
				editors[name] = {}
				editors[name].id = editedmaps
				editedmaps = editedmaps + 1

				main.playing[name] = false
				return true, maps.new_map(name)
			else
				return false, "A map is already being edited!"
			end
		elseif params[1] == "edit" and params[2] then
			if not editors[name] then
				editors[name] = {}
				editors[name].id = editedmaps
				editedmaps = editedmaps + 1

				main.playing[name] = false
				return maps.edit_map(name, params[2])
			else
				return false, "A map is already being edited!"
			end
		elseif params[1] == "save" then
			if editors[name] then
				return true, maps.show_save_form(name)
			else
				return false, "You aren't editing/creating a map!"
			end
		else
			return false, "Options: help/h | new | edit <mapname> | save"
		end
	end
})

function maps.new_map(pname)
	local player = minetest.get_player_by_name(pname)
	local mpos = vector.new(100 * editors[pname].id, 777, 0)

	editors[pname].action = "new"
	editors[pname].settings = {
		skybox = "TropicalSunnyDay",
		creator = pname,
	}

	minetest.emerge_area(vector.subtract(mpos, vector.new(20, 0, 20)), vector.add(mpos, vector.new(20, 16, 20)))
	minetest.place_schematic(mpos, minetest.get_modpath("maps").."/schems/base.mts", 0, {}, true,
		{place_center_x = true, place_center_y=false, place_center_z=true})

	player:set_pos(vector.new(100 * editors[pname].id, 778, 0))

	return "Map container placed, build away!"
end

function maps.save_map(pname, mname, creator, skybox, modes)
	local path = maps.mappath..mname.."/"
	minetest.mkdir(path)
	local conf, error = io.open(path.."map.conf", "w")
	local startpos = vector.new(100 * editors[pname].id, 777+8, 0)

	if not minetest.find_node_near(startpos, 20, "maps:spawnpoint", true) then
		return false, "You must place at least one player spawner first!"
	end

	if not minetest.find_node_near(startpos, 20, "maps:itemspawner", true) then
		return false, "You must place at least one item spawner first!"
	end

	if not conf then return false, error end
	if maps.map_exists(mname) and editors[pname].map and editors[pname].map == mname then
		minetest.chat_send_player(pname, "Overwriting map "..dump(mname).."...")
	end

	conf:write("name = <"..mname..">")
	conf:write("\ncreator = <"..creator..">")
	conf:write("\nskybox = <"..skybox..">")
	conf:write("\nmodes = <"..minetest.serialize(modes)..">")

	for finame, item in pairs({pspawns = "maps:spawnpoint", ispawns = "maps:itemspawner"}) do
		local pos = minetest.find_node_near(startpos, 20, item, true)
		local positions = {}

		while pos do
			local rpos = vector.new(pos.x-(100 * editors[pname].id), pos.y-777, pos.z)
			table.insert(positions, rpos)
			minetest.remove_node(pos)
			pos = minetest.find_node_near(startpos, 20, item, true)
		end

		if positions then
			conf:write("\n"..finame.." = <"..minetest.serialize(positions)..">")
		end
	end

	conf:close()

	local r = minetest.create_schematic(
		vector.new((100 * editors[pname].id)-19, 778, -19),
		vector.new((100 * editors[pname].id)+19, 778+14, 19),
		{}, path.."map.mts", {}
	)

	if r then
		maps.new_map(pname)

		return true, "Saved map!"
	end

	return false, "Failed to create map schematic"
end

function maps.edit_map(pname, mname)
	local player = minetest.get_player_by_name(pname)
	local mpos = vector.new(100 * editors[pname].id, 777, 0)
	local mpos_up = vector.new(100 * editors[pname].id, 778, 0)

	if not maps.map_exists(mname) then return false, "No such map!" end

	editors[pname].action = "editing"
	editors[pname].map = mname
	editors[pname].settings = {
		name = pname.."s Map"
	}

	minetest.emerge_area(vector.subtract(mpos, vector.new(20, 0, 20)), vector.add(mpos, vector.new(20, 16, 20)))
	minetest.place_schematic(mpos, minetest.get_modpath("maps").."/schems/base.mts", 0, {}, true,
		{place_center_x = true, place_center_y=false, place_center_z=true})
	minetest.place_schematic(mpos_up, maps.mappath..mname.."/map.mts", 0, {}, true,
		{place_center_x = true, place_center_y=false, place_center_z=true})

	local conf, error = io.open(maps.mappath..mname.."/map.conf")

	if not conf then return false, error end

	local cfile = conf:read("*all")

	editors[pname].settings.name = cfile:match("name = <.->"):sub(9, -2)
	editors[pname].settings.creator = cfile:match("creator = <.->"):sub(12, -2)
	editors[pname].settings.skybox = cfile:match("skybox = <.->"):sub(11, -2)
	editors[pname].settings.modes = minetest.deserialize(cfile:match("modes = <.->"):sub(10, -2))

	local playerspawns = minetest.deserialize(cfile:match("pspawns = <.->"):sub(12, -2))
	local itemspawns = minetest.deserialize(cfile:match("ispawns = <.->"):sub(12, -2))

	conf:close()

	while playerspawns and playerspawns[1] do
		playerspawns[1].y = playerspawns[1].y + 777
		playerspawns[1].x = playerspawns[1].x + (100 * editors[pname].id)
		minetest.set_node(playerspawns[1], {name = "maps:spawnpoint"})
		table.remove(playerspawns, 1)
	end

	while itemspawns and itemspawns[1] do
		itemspawns[1].y = itemspawns[1].y + 777
		itemspawns[1].x = itemspawns[1].x + (100 * editors[pname].id)
		minetest.set_node(itemspawns[1], {name = "maps:itemspawner"})
		table.remove(itemspawns, 1)
	end

	while minetest.get_node(mpos_up).name ~= "air" do
		mpos_up.y = mpos_up.y + 1
	end

	player:set_pos(mpos_up)

	return true, "Map placed, edit away!"
end

function maps.map_exists(name)
	for _, n in pairs(minetest.get_dir_list(minetest.get_worldpath().."/maps/", true)) do
		if n == name then
			return true
		end
	end

	return false
end

local rand_limit = 0
function maps.get_rand_map()
	local list = minetest.get_dir_list(minetest.get_worldpath().."/maps/", true)

	if not list or #list == 0 then return end

	local map = list[math.random(1, #list)]

	if vc_info.mode_running then
		while true do
			local conf, error = io.open(maps.mappath..map.."/map.conf")

			if not conf then
				main.log("error", error)
				map = list[math.random(1, #list)]
			else
				local modes = minetest.deserialize(conf:read("*all"):match("modes = <.->"):sub(10, -2))
				conf:close()

				if modes == nil then
					main.log("Map "..dump(map).." is corrupted or out of date!", "error")
				else
					local found = false
					for _, mapdef in ipairs(modes) do
						if mapdef.name == main.current_mode.name and mapdef.enabled then
							found = true
							break
						elseif mapdef.name == main.current_mode.full_name then
							found = true
							main.log("error", "The map "..dump(map).." Is outdated. Please edit and re-save it to fix")
						end
					end
					if found then break end
				end
			end

			if rand_limit < #list * 2 then
				rand_limit = rand_limit + 1
			else
				rand_limit = 0
				main.log("No working maps found after 10 tries. Please alert the server admin", "error")
				return
			end
		end
	end

	return map
end

function maps.load_map(name)
	local pos = vector.new(0, 0, 0)
	local conf, error = io.open(maps.mappath..name.."/map.conf")
	local mapdef = {}

	if not conf then return error end
	local cfile = conf:read("*all")
	conf:close()

	mapdef.name = cfile:match("name = <.->"):sub(9, -2)
	mapdef.creator = cfile:match("creator = <.->"):sub(12, -2)
	mapdef.skybox = cfile:match("skybox = <.->"):sub(11, -2)
	mapdef.modes = minetest.deserialize(cfile:match("modes = <.->"):sub(10, -2))
	mapdef.playerspawns = minetest.deserialize(cfile:match("pspawns = <.->"):sub(12, -2)) or {{0, 5, 0}}
	mapdef.itemspawns = minetest.deserialize(cfile:match("ispawns = <.->"):sub(12, -2)) or {{0, 5, 0}}


	minetest.place_schematic(pos, maps.mappath..name.."/map.mts", 0, {}, true,
		{place_center_x = true, place_center_y=false, place_center_z=true})

	return mapdef
end

local function get_modes_string(name)
	local string = ""

	for _, def in ipairs(editors[name].settings.modes) do
		local color = "#00ff32"

		if not def.enabled then color = "#ff0000" end

		string = string .. color .. def.name .. ","
	end

	return(string:sub(1, -2))
end

local function tidy_modes(name)
	if not editors[name].settings.modes then
		editors[name].settings.modes = {}
	end

	for modename, def in pairs(main.modes) do
		local found = false

		if editors[name].settings.modes then
			for k, v in pairs(editors[name].settings.modes) do
				if v.name == modename then
					found = true
				end
			end
		end

		if not found then
			table.insert(editors[name].settings.modes, {name = modename, enabled = true})
		end
	end

	if editors[name].settings.modes then
		for key, def in pairs(editors[name].settings.modes) do
			local found = false

			for k, v in pairs(main.modes) do
				if k == def.name then
					found = true
					break
				end
			end

			if not found then
				editors[name].settings.modes[key] = nil
			end
		end
	end
end

function maps.show_save_form(player)
	local p = minetest.get_player_by_name(player)

	tidy_modes(player)

	skybox.set(p, main.get_sky(editors[player].settings.skybox))
	local one, two, three = p:get_sky()
	p:set_sky(one, two, three, false)

    local form = "size[8,6]" ..
    "bgcolor[#000000aa;true]" ..
    "label[3,0.1;Map Creation Form]" ..
    "field[0.5,1.45;3.5,1;map_name;Map Name;" .. editors[player].settings.name .. "]" ..
    "field_close_on_enter[map_name;false]" ..
    "field[0.5,2.65;3.5,1;map_creator;Map Creator;" .. editors[player].settings.creator .. "]" ..
    "field_close_on_enter[map_creator;false]" ..
    "label[0.2,3.25;Map Skybox]" ..
	"dropdown[0.2,3.65;3.6,1;map_skybox;" .. table.concat(skybox.skies, ",") .. ";"..
	main.get_sky(editors[player].settings.skybox) .."]" ..
    "label[4,0.8;Compatible Modes]" ..
    "textlist[4,1.2;3.9,3.15;map_modes;" .. get_modes_string(player) .. "]" ..
    "button_exit[2.4,4.8;3.2,1;map_save;Save Map]"

    minetest.show_formspec(player, "maps:save_form", form)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "maps:save_form" then return end

	local name = player:get_player_name()
	local modes = minetest.explode_textlist_event(fields.map_modes)

	if modes.type == "DCL" and editors[name].settings.modes and #editors[name].settings.modes > 0 then
		editors[name].settings.modes[modes.index].enabled = not editors[name].settings.modes[modes.index].enabled
	end

	if fields.map_save then
		local success, msg = maps.save_map(
			name, fields.map_name, fields.map_creator,
			fields.map_skybox, editors[name].settings.modes
		)

		minetest.chat_send_player(name, msg)

		if success then
			editors[name] = nil
			main.playing[name] = true
			main.join_player(minetest.get_player_by_name(name))
		end
	elseif not fields.quit then
		editors[player].settings.name = fields.map_name
		editors[name].settings.creator = fields.map_creator
		editors[name].settings.skybox = fields.map_skybox
		maps.show_save_form(name, fields.map_name)
	end
end)

function main.spawn_rand_drop(pos)
	local drops = main.current_mode.mode.drops

	if not drops then return end

	local itemspawns = main.current_mode.itemspawns
	local spawnpos = pos or itemspawns[math.random(1, #itemspawns)]

	for item, chance in pairs(drops) do
		if item ~= "default" then
			if math.random(1, chance) == 1 then
				minetest.log("action", "Dropped "..dump(item).." at "..minetest.pos_to_string(spawnpos))
				minetest.add_item(spawnpos, item)
				return
			end
		end
	end

	if drops.default then
		minetest.add_item(spawnpos, drops.default)
	end
end

local dropstep = 0
minetest.register_globalstep(function(dtime)
	if not vc_info.mode_running then return end

	local dropint = main.current_mode.mode.drop_interval
	local online_players = #minetest.get_connected_players()

	if dropint and dropstep >= dropint - (online_players * 5) and online_players >= 1 then
		dropstep = 0

		main.spawn_rand_drop()
	else
		dropstep = dropstep + dtime
	end
end)

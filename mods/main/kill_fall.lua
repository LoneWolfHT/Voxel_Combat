local checkstep = 0
minetest.register_globalstep(function(dtime)
	if checkstep <= 5 then
		checkstep = checkstep + dtime
	else
		checkstep = 0

		for _, player in pairs(minetest.get_connected_players()) do
			if player:get_pos().y < -5 then
				player:set_hp(0, {reason = "set_hp"})
			end
		end
	end
end)
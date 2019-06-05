minetest.register_on_joinplayer(function(player)
	local inv = player:get_inventory()

	if not minetest.check_player_privs(player, {map_maker = true}) then
		inv:set_size("main", 8*2)
		player:hud_set_hotbar_itemcount(6)
		player:hud_set_hotbar_image("hotbar_6.png")

		for _, s in ipairs(inv:get_list("main")) do
			inv:remove_item("main", s)
		end

		if main.current_mode then
			if main.current_mode.mode.starter_items then
				for k, item in ipairs(main.current_mode.mode.starter_items) do
					inv:add_item("main", item)
				end
			end
		end
	else
		inv:set_size("main", 8*4)
		player:hud_set_hotbar_itemcount(8)
		player:hud_set_hotbar_image("hotbar_8.png")
	end

	player:hud_set_flags({healthbar = true, breathbar = true})

end)
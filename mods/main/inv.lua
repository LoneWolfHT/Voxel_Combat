minetest.register_on_joinplayer(function(player)
	local inv = player:get_inventory()

	if not minetest.check_player_privs(player, {map_maker = true}) then
		inv:set_size("main", 8*2)
		player:hud_set_hotbar_itemcount(6)
		player:hud_set_hotbar_image("hotbar_6.png")
	else
		inv:set_size("main", 8*4)
		player:hud_set_hotbar_itemcount(8)
		player:hud_set_hotbar_image("hotbar_8.png")
	end

	player:hud_set_flags({healthbar = true, breathbar = true})

end)

sfinv.override_page("sfinv:crafting", {
	title = "Main",
	get = function(_, player, context)
		return sfinv.make_formspec(player, context, [[
				image[0,4.7;1,1;gui_hb_bg.png]
				image[1,4.7;1,1;gui_hb_bg.png]
				image[2,4.7;1,1;gui_hb_bg.png]
				image[3,4.7;1,1;gui_hb_bg.png]
				image[4,4.7;1,1;gui_hb_bg.png]
				image[5,4.7;1,1;gui_hb_bg.png]
				image[6,4.7;1,1;gui_hb_bg.png]
				image[7,4.7;1,1;gui_hb_bg.png]
				image[0.06,3.55;0.8,0.8;creative_trash_icon.png]
				list[detached:creative_trash;main;0,3.45;1,1;]
			]], true)
	end
})
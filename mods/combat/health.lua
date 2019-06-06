minetest.register_craftitem("combat:medkit", {
	description = "Medkit",
	inventory_image = "combat_medkit.png",
	stack_max = 5,
	groups = {hold_limit = 5},
	range = 0,
	on_use = function(itemstack, user)
		if user:get_hp() >= 18 then return end

		for i = 0.6, 2.4, 0.6 do
			minetest.after(i, function()
				if user:get_hp() > 0 then
					user:set_hp(user:get_hp()+4, {reason = "set_hp"})
				end
			end)
		end

		itemstack:take_item(1)

		return itemstack
	end
})
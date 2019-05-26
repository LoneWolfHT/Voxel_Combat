local function can_pickup(item)
	for i in pairs(main.current_mode.mode.drops) do
		if item:sub(1, i:len()) == i then return true end
	end

	if item:find("shooter_guns:ammo") then return true end

	return false
end

minetest.register_globalstep(function(dtime)
	for _, player in ipairs(minetest.get_connected_players()) do
		if player:get_hp() > 0 then
			local pos = player:get_pos()
			local inv = player:get_inventory()

			for _, object in ipairs(minetest.get_objects_inside_radius(pos, 1)) do
				local self = object:get_luaentity()

				if not object:is_player() and self and self.name == "__builtin:item" and
				self.itemstring ~= "" then
					if inv and can_pickup(self.itemstring) then
						inv:add_item("main", ItemStack(self.itemstring))
						self._removed = true
						object:remove()
					end
				end
			end
		end
	end
end)

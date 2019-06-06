local function inv_find(inv, stack)
	local count = 0

	for _, s in ipairs(inv:get_list("main")) do
		if s:get_name():gsub("_loaded", "") == stack:gsub("_loaded", "") then
			count = count + s:get_count()
		end
	end

	return count
end

local function can_pickup(inv, item)
	local limit = minetest.get_item_group(item:get_name(), "hold_limit")

	if item:get_count() <= 0 then return false end

	if limit == 0 then
		return true
	elseif limit > 0 then
		if inv_find(inv, item:get_name()) < limit then
			return true
		end
	end

	return false
end

minetest.register_globalstep(function()
	for _, player in ipairs(minetest.get_connected_players()) do
		if player:get_hp() > 0 then
			local pos = player:get_pos()
			local inv = player:get_inventory()

			for _, object in ipairs(minetest.get_objects_inside_radius(pos, 1.1)) do
				local self = object:get_luaentity()

				if not object:is_player() and self and self.name == "__builtin:item" and
				self.itemstring ~= "" then
					if inv then
						local drop = ItemStack(self.itemstring)

						while inv:room_for_item("main", drop:get_name()) and can_pickup(inv, drop) do
							inv:add_item("main", drop:get_name())
							drop:take_item(1)
						end

						if drop:get_count() <= 0 then
							object:remove()
						else
							self.itemstring = drop:get_name().." "..drop:get_count()
						end

					end
				end
			end
		end
	end
end)

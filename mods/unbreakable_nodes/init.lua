for name, def in pairs(minetest.registered_nodes) do
	local newdef = {groups = def.groups}

	newdef.groups.unbreakable = 1
	newdef.groups.snappy = nil
	newdef.groups.oddly_breakable_by_hand = nil
	newdef.groups.crumbly = nil
	newdef.groups.dig_immediate = nil

	minetest.override_item(name, newdef)
end
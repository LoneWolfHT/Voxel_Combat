shooter.config.allow_entities = true
shooter.config.shooter_allow_nodes = false

for name, def in pairs(minetest.registered_nodes) do
	local newdef = {groups = def.groups}

	newdef.groups.unbreakable = 1
	newdef.groups.snappy = nil
	newdef.groups.oddly_breakable_by_hand = nil
	newdef.groups.crumbly = nil
	newdef.groups.dig_immediate = nil
	newdef.groups.falling_node = nil
	newdef.on_rightclick = nil

	if name:find("sapling") then
		newdef.on_construct = default.grow_sapling
	end

	if name:find("lava") then
		newdef.damage_per_second = 100
	end

	if name:find("dirt") or name:find("sand") then
		newdef.groups.zombie_ground = 1
	end

	minetest.override_item(name, newdef)
end

for name, def in pairs(minetest.registered_items) do
	local newdef = {groups = def.groups}

	if name:find("shooter_guns:") then
		newdef.range = 0
	end

	if name == "shooter_guns:ammo" then
		newdef.groups.hold_limit = 17
	end

	minetest.override_item(name, newdef)
end

for name in pairs(minetest.registered_abms) do
	minetest.registered_abms[name] = nil
end

for name in pairs(minetest.registered_lbms) do
	minetest.registered_lbms[name] = nil
end

default.can_grow = function() return true end

minetest.registered_entities["__builtin:item"].on_punch = nil
minetest.registered_entities["__builtin:item"].static_save = false
minetest.registered_entities["__builtin:item"].pointable = false

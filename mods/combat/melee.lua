minetest.register_tool("combat:knife", {
	description = "Knife",
	inventory_image = "combat_knife.png",
	range = 1.5,
	wield_scale = {x = 0.7, y = 0.7, z = 0.7},
	groups = {hold_limit = 1},
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=0,
		damage_groups = {fleshy=1},
	},
})

minetest.register_tool("combat:sword", {
	description = "Sword",
	inventory_image = "combat_sword.png",
	range = 2.5,
	wield_scale = {x = 1.3, y = 1.5, z = 1},
	groups = {hold_limit = 1},
	tool_capabilities = {
		full_punch_interval = 0.8,
		max_drop_level=1,
		damage_groups = {fleshy=3},
	},
	sound = {breaks = "default_tool_breaks"},
})
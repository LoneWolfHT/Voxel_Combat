minetest.register_tool("vc_weapons:knife", {
	description = "Knife",
	inventory_image = "weapons_knife.png",
	range = 1.5,
	wield_scale = {x = 0.7, y = 0.7, z = 0.7},
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level=0,
		damage_groups = {fleshy=2},
	},
})

minetest.register_tool("vc_weapons:sword", {
	description = "Sword",
	inventory_image = "weapons_sword.png",
	range = 2.5,
	wield_scale = {x = 1.3, y = 1.5, z = 1},
	tool_capabilities = {
		full_punch_interval = 0.8,
		max_drop_level=1,
		damage_groups = {fleshy=4},
	},
	sound = {breaks = "default_tool_breaks"},
})
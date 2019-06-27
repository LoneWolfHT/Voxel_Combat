minetest.register_node("maps:spawnpoint", {
	description = "Spawnpoint",
	tiles = {"air.png"},
	groups = {unbreakable = 1},
	walkable = true,
	pointable = true,
	paramtype = "light",
	sunlight_propagates = true,
	light_source = 1,
})

minetest.register_node("maps:itemspawner", {
	description = "Item Spawner",
	tiles = {"default_mese_crystal.png"},
	groups = {unbreakable = 1},
	walkable = true,
	pointable = true,
	paramtype = "light",
	sunlight_propagates = true,
	light_source = 1,
})

minetest.register_node("maps:light", {
	drawtype = "airlike",
	description = "Invisible Light",
	inventory_image = "default_meselamp.png^air.png",
	walkable = false,
	pointable = false,
	paramtype = "light",
	sunlight_propagates = true,
	light_source = minetest.LIGHT_MAX,
})

minetest.register_node("maps:barrier", {
	drawtype = "airlike",
	description = "Invisible Barrier",
	inventory_image = "default_meselamp.png^air.png",
	walkable = false,
	pointable = true,
	paramtype = "light",
	sunlight_propagates = true,
})

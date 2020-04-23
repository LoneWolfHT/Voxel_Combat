for gun, def in pairs(shooter.registered_weapons) do
	local newdef = {
		groups = minetest.registered_items[gun].groups
	}

	if gun == "shooter_guns:pistol" then
		def.spec.rounds = 10
		def.spec.tool_caps = {full_punch_interval=0.35, damage_groups={fleshy=2}}

		newdef.groups.hold_limit = 1
	elseif gun == "shooter_guns:rifle" then
		def.spec.rounds = 15
		def.spec.tool_caps = {full_punch_interval=1, damage_groups={fleshy=4}}

		newdef.groups.hold_limit = 1
	elseif gun == "shooter_guns:shotgun" then
		def.spec.rounds = 4
		def.spec.spread = 15
		def.spec.shots = 20
		def.spec.tool_caps = {full_punch_interval=1.5, damage_groups={fleshy=1}}

		newdef.groups.hold_limit = 1
	elseif gun == "shooter_guns:machine_gun" then
		def.spec.rounds = 27
		def.spec.tool_caps = {full_punch_interval=0.15, damage_groups={fleshy=2}}

		newdef.groups.hold_limit = 1
	end

	def.spec.wear = math.ceil(65535 / def.spec.rounds)

	shooter.registered_weapons[gun] = def
	minetest.override_item(gun, newdef)
	minetest.override_item(gun.."_loaded", newdef)
end

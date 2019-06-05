for gun, def in pairs(shooter.registered_weapons) do
	if gun == "shooter_guns:pistol" then
		def.spec.rounds = 10
		def.spec.tool_caps = {full_punch_interval=0.33, damage_groups={fleshy=1}}
	elseif gun == "shooter_guns:rifle" then
		def.spec.rounds = 15
		def.spec.tool_caps = {full_punch_interval=1, damage_groups={fleshy=4}}
	elseif gun == "shooter_guns:shotgun" then
		def.spec.rounds = 4
		def.spec.tool_caps = {full_punch_interval=1.5, damage_groups={fleshy=2}}
	elseif gun == "shooter_guns:machine_gun" then
		def.spec.rounds = 27
		def.spec.tool_caps = {full_punch_interval=0.15, damage_groups={fleshy=1}}
	end

	def.spec.wear = math.ceil(65535 / def.spec.rounds)

	shooter.registered_weapons[gun] = def
end
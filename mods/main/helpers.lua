function main.get_sky(name)
	local sky = 1

	table.foreach(skybox.skies, function(k, v)
		if v == name then
			sky = k
		end
	end)

	return sky
end

function main.clear_inv(inv)
	for _, s in ipairs(inv:get_list("main")) do
		inv:remove_item("main", s)
	end
end

function main.give_starter_items(inv)
	main.clear_inv(inv)

	if main.current_mode then
		if main.current_mode.mode.starter_items then
			for _, item in ipairs(main.current_mode.mode.starter_items) do
				inv:add_item("main", item)
			end
		end
	end
end
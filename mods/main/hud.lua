main.playerhuds = {}

function main.sethud_all(text, timeout)
	minetest.log("Set hud of all players to "..dump(text))

	if text == "" and main.playerhuds then
		for k, p in ipairs(minetest.get_connected_players()) do
			p:hud_remove(main.playerhuds[p:get_player_name()])
		end

		main.playerhuds = {}
	else
		for k, p in ipairs(minetest.get_connected_players()) do
			local name = p:get_player_name()

			if main.playerhuds[name] then
				p:hud_remove(main.playerhuds[name])
			end

			main.playerhuds[name] = p:hud_add({
				hud_elem_type = "text",
				position = {x=0.5, y=0.4},
				name = name.."_hud",
				scale = {x=100, y=100},
				text = text,
				number = 0xffe700,
				direction = 1,
				alignment = {x=0, y=0},
				offset = {x=0, y=0},
			})

			if timeout then
				minetest.after(timeout, main.sethud_all, "")
			end
		end
	end

	minetest.log("Done setting player huds")
end

function main.sethud_player(name, text, timeout)
	local player = minetest.get_player_by_name(name)

	if not player then
		minetest.log("error", "Tried to set the hud of a player that isn't online! "..dump(name))
		return
	end

	minetest.log("Setting hud of "..name.." to "..dump(text))

	if text == "" and main.playerhuds[name] then
		player:hud_remove(main.playerhuds[name])
	else
		if main.playerhuds[name] then
			player:hud_remove(main.playerhuds[name])
		end

		main.playerhuds[name] = player:hud_add({
			hud_elem_type = "text",
			position = {x=0.5, y=0.4},
			name = name.."_hud",
			scale = {x=100, y=100},
			text = text,
			number = 0x00b500,
			direction = 1,
			alignment = {x=0, y=0},
			offset = {x=0, y=0},
		})

		if timeout then
			minetest.after(timeout, main.sethud_player, name, "")
		end
	end

	minetest.log("Done setting "..name.."\'s hud")
end

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()

	if main.playerhuds[name] then
		main.playerhuds[name] = nil
	end
end)

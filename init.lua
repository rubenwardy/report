local S = minetest.get_translator("report")

local storage = minetest.get_mod_storage()
assert(storage, "mod_storage is required")

local function get_modo_list()
	local store = storage:get_string("report")
	if store then
		return minetest.deserialize(store) or {}
	end
	return nil
end

local function is_known_modo(name)
	for _, modo in ipairs(get_modo_list()) do
		if modo == name then
			return true
		end
	end
	return false
end

minetest.register_on_joinplayer(function(player)
	-- Get player privs
	local player_name = player:get_player_name()
	local is_modo = minetest.check_player_privs(player_name, {kick = true, ban = true})

	-- Is player a known moderator?
	local known = is_known_modo(player_name)

	-- Add or remove the player to/from moderators list
	if not known and is_modo then
		local modos = get_modo_list()
		table.insert(modos, player_name)
		storage:set_string("report", minetest.serialize(modos))
	elseif known and not is_modo then
		local modos = get_modo_list()
		for i, modo in ipairs(modos) do
			if modo == player_name then
				table.remove(modos, i)
				storage:set_string("report", minetest.serialize(modos))
				break
			end
		end
	end
end)

minetest.register_chatcommand("report", {
	description = S("Send a report to moderators. '/report modos_list' to get the list of moderators."),
	params = "<msg>",
	func = function(name, param)
		param = param:trim()
		if param == "" then
			return false, S("Please write a message for the report. If it's about one or several players in particular, please give their name.")
		end
		if param == "modos_list" then
			return true, S("Moderators list: @1", table.concat(get_modo_list(), ", "))
		end
		local _, count = string.gsub(param, " ", "")
		if count == 0 then
			minetest.chat_send_player(name, S("If you are reporting a player's attitude, you should also say why. (Ex: insult, sabotage)"))
		end

		-- Send to online moderators / admins
		-- Get comma separated list of online moderators and admins
		local modos_online = {}
		for _, player in pairs(minetest.get_connected_players()) do
			local toname = player:get_player_name()
			if is_known_modo(toname) then
				table.insert(modos_online, toname)
				minetest.chat_send_player(toname, S("-!- @1 has reported: @2", name, param))
			end
		end

		local admin = minetest.setting_get("name")

		if #modos_online > 0 then
			local mod_list = table.concat(modos_online, ", ")
			email.send_mail(name, admin, S("Report: @1 (online moderator(s): @2)", param, mod_list))
			for _, modo in ipairs(get_modo_list()) do
				if modo ~= admin then
					email.send_mail(name, modo, S("Report: @1 (online moderator(s): @2)", param, mod_list))
				end
			end
			return true, S("Reported. Online moderator(s): @1", mod_list)
		else
			email.send_mail(name, admin, S("Report: @1 (no online moderator)", param))
			for _, modo in ipairs(get_modo_list()) do
				if modo ~= admin then
					email.send_mail(name, modo, S("Report: @1 (no online moderator)", param))
				end
			end
			return true, S("Reported. We will get back to you.")
		end
	end
})

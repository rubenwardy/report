if not chatplus.send_mail then
	error("You need to update chatplus!")
end

minetest.register_chatcommand("report", {
	func = function(name, param)
		-- Send to online moderators / admins
		-- Get comma separated list of online moderators and admins
		local mods = ""
		for _, player in pairs(minetest.get_connected_players()) do
			local name = player:get_player_name()
			if minetest.check_player_privs(name, {kick=true,ban=true}) then
				if mods ~= "" then
					mods = mods .. ", "
				end
				mods = mods .. name
				minetest.chat_send_player(name, "-!- " .. name .. " reported: " .. param)
			end
		end
		
		-- I hope that none of the moderators are called "none"!
		if mods == "" then
			mods = "none"
		end
		chatplus.send_mail(name, minetest.setting_get("name"),
			"Report: " .. param .. " (mods online: " .. mods .. ")")
	end
})

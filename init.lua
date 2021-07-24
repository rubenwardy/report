local function save_modo(name)

end

local function get_modo_list()

end

minetest.register_on_joinplayer(function(player)
		-- 1. Obtenir la liste des modérateur connus
		--    local modo_saved = get_modo_list()
		-- 2. Obtenir les privs du player
		-- 3. Si player n'est pas dans la liste modos connus et a privs modos alors
		-- 4.  Ajouter nom du player dans liste modos connus
		-- 5. Sinon si player est dans liste modos connus et n'a pas privs modos alors
		-- 6.  Supprimer nom du player de la liste modos connus.
		-- 7. Fin
end)

minetest.register_chatcommand("report", {
	func = function(name, param)
		param = param:trim()
		if param == "" then
			return false, "Veuillez écrire un message pour le rapport. " ..
				"Si il s'agit d'un (de) joueur(s) en particulier, veuillez aussi indiquer son (leur) nom(s)."
		end
		local _, count = string.gsub(param, " ", "")
		if count == 0 then
			minetest.chat_send_player(name, "Si vous rapportez l'attitude d'un joueur, " ..
				"vous devriez aussi dire quelle en est la raison. (Ex: insulte, sabotage)")
		end

		-- Send to online moderators / admins
		-- Get comma separated list of online moderators and admins
		local mods = {}
		for _, player in pairs(minetest.get_connected_players()) do
			local toname = player:get_player_name()
			if minetest.check_player_privs(toname, {kick = true, ban = true}) then
				table.insert(mods, toname)
				minetest.chat_send_player(toname, "-!- " .. name .. " a rapporté : " .. param)
			end
		end

		if #mods > 0 then
			mod_list = table.concat(mods, ", ")
			email.send_mail(name, minetest.setting_get("name"),
								 "Rapport: " .. param .. " (modos connecté(s) : " .. mod_list .. ")")
			return true, "Rapporté. Moderateur(s) connecté(s) : " .. mod_list
		else
			email.send_mail(name, minetest.setting_get("name"),
				"Rapport: " .. param .. " (pas de modo connecté)")
			return true, "Rapporté. On reviendra vers vous."
		end
	end
})

minetest.log("action", "[report] loaded.")

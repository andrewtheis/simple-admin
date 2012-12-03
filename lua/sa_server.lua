// Send the files we need
AddCSLuaFile("autorun/sa.lua")
AddCSLuaFile("sa_client.lua")
AddCSLuaFile("sa_config.lua")
AddCSLuaFile("sa_menu.lua")
AddCSLuaFile("sa_player_extension.lua")
AddCSLuaFile("sa_shared.lua")


// Include files we need
include("sa_shared.lua")
include("sa_functions.lua")


// Add all the console commands
concommand.Add("sa_ban", saBan)
concommand.Add("sa_cleanup", saCleanup)
concommand.Add("sa_create_vote", saCreateVote)
concommand.Add("sa_event", saEvent)
concommand.Add("sa_kick", saKick)
concommand.Add("sa_rcon", saRCon)
concommand.Add("sa_rules", saRules)
concommand.Add("sa_set_vote_end_action", saSetVoteEndAction)
concommand.Add("sa_teleport_to", saTeleportTo)
concommand.Add("sa_vote", saVote)
concommand.Add("sa_warn", saWarn)


// Called when a player tries to enter a vehicle
function saCanEnter(pl, vehicle, role)
	if !saIsTheirs(pl, vehicle) then return false end
end


// Called when a player tries to pickup stuff with the phys gun
function saCanPickup(pl, ent)
	if ent && ent:IsValid() && ent:IsPlayer() && pl:IsAdmin() then return true end
	if !saIsTheirs(pl, ent) then return false end
end


// Called when a player tries to unfreeze a player's props
function saCanPhysgunReload(weapon, pl)
	local trace = util.TraceLine(util.GetPlayerTrace(pl))
	if !saIsTheirs(pl, trace.Entity) then return false end
end


// Checks to see if they can spawn yet
function saCanSpawnEnt(pl)
	if event_in_progress == 1 && (!pl:IsAdmin() || event_includes_admins == 1) then
		pl:FancyMsg("NOTIFY_ERROR", "An event is in progress. You may not spawn entities at this time.", nil)
		return false
	end
end


// Checks to see if a player can use a tool on an entity
function saCanTool(pl, trace, mode)
	local ent = trace.Entity
	if (mode == "remover" && ent.owner == "World") || !saIsTheirs(pl, ent) then return false end
end


// Called when a player trise to Use something
function saCanUse(pl, ent)
	if !saIsTheirs(pl, ent) then return false end
end


// Called after all the entities have been loaded
function saInitPostEntity()
	for _, ent in pairs(ents.GetAll()) do
		ent.owner = "World"
	end
end


// Called when an NPC dies
function saOnNPCKilled(ent, killer, weapon)
	if killer && killer:IsPlayer() && SA_NPC_KILL_SCORE > 0 then
		killer:AddFrags(SA_NPC_KILL_SCORE)
	end
end


// Called when the player tries to pickup a weapon
function saPlayerCanPickupWeapon(pl, weapon)
	if pl:IsAdmin() && event_includes_admins == 0 then return true end
	
	// Are we in event mode
	if (event_in_progress == 0 && (#SA_ALLOWED_WEAPONS == 0 || table.HasValue(SA_ALLOWED_WEAPONS, weapon:GetClass()))) || (event_in_progress == 1 && table.HasValue(event_weapons, weapon:GetClass())) then
		return true
	else
		pl:FancyMsg("NOTIFY_ERROR", "You may not use that weapon at this time.", weapon)
		weapon:Remove()
		return false
	end
end


// Called when a player disconnects
function saPlayerDisconnected(pl)
	if GAMEMODE.Name == "Sandbox" then
		local pl_uid = pl:UniqueID()
		local pl_name = pl:Name()
		local fake_pl = {UniqueID = function() return pl_uid end, SendLua = function() end} 
		
		timer.Create("sa_cleanup_" .. pl_uid, SA_CLEANUP_TIME, 1, function()
			cleanup.CC_Cleanup(fake_pl, "gmod_cleanup", "")
			PrintMessage(HUD_PRINTTALK, Format("%s's props were automatically removed.", pl_name))
		end)
	end
	
	if pl:GetNWInt("reserved_slot_used") > 0 then
		used_reserved_slots = used_reserved_slots - 1
	end
end
hook.Add("PlayerDisconnected", "saPlayerDisconnectedHook", saPlayerDisconnected)


// Called when a player first spawns
function saPlayerInitialSpawn(pl)
	pl:SetNWInt("has_voted", 0)
	pl:SetNWInt("show_rules_time", 0)
	pl:SetNWInt("reserved_slot_used", 0)
	
	if pl:IsVIP() then
		if used_reserved_slots < SA_RESERVED_SLOTS then
			pl:PrintMessage(HUD_PRINTTALK, "You are using a reserved slot.")
			used_reserved_slots = used_reserved_slots + 1
			pl:SetNWInt("reserved_slot_used", used_reserved_slots)
		end
	elseif #player.GetAll() > MaxPlayers() - (SA_RESERVED_SLOTS - used_reserved_slots) then
		timer.Simple(1, game.ConsoleCommand, "kickid "..pl:UserID().." \""..SA_RESERVED_SLOT_MESSAGE.."\"\n")
	end
end
hook.Add("PlayerInitialSpawn", "saPlayerInitialSpawnHook", saPlayerInitialSpawn)


// Called when a player leaves a vehicle
function saPlayerLeaveVehicle(pl)
	if event_in_progress == 1 then
		pl:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
	end
end
hook.Add("PlayerLeaveVehicle", "saPlayerLeaveVehicleHook", saPlayerLeaveVehicle)


// Called by PlayerSpawn
function saPlayerLoadout(pl)
	pl:StripWeapons()
	
	// Do normal loadout
	if (event_in_progress == 0 && pl:IsAdmin()) || (event_in_progress == 1 && pl:IsAdmin() && event_includes_admins == 0) then
		GAMEMODE:PlayerLoadout(pl)
		return
	end
	
	// Now, execute the following based on event or not
	if event_in_progress == 1 then
		for _, wep in pairs(event_weapons) do
			if wep != "" then
				pl:Give(wep)
			end
		end
	else
		if #SA_ALLOWED_WEAPONS > 0 then
			for _, wep in pairs(SA_ALLOWED_WEAPONS) do
				pl:Give(wep)
			end
		else
			GAMEMODE:PlayerLoadout(pl)
		end
	end

	
	// Now give the weapon correct ammo
	for _, wep in pairs(pl:GetWeapons()) do
		local wep_class = wep:GetClass()
		
		if wep:GetPrimaryAmmoType() && SA_WEAPON_AMMO[wep_class] then
			pl:RemoveAmmo(10000, wep:GetPrimaryAmmoType())
			pl:GiveAmmo(SA_WEAPON_AMMO[wep_class][1], wep:GetPrimaryAmmoType())
		end
		
		if wep:GetSecondaryAmmoType() && SA_WEAPON_AMMO[wep_class] then
			pl:RemoveAmmo(10000, wep:GetSecondaryAmmoType())
			pl:GiveAmmo(SA_WEAPON_AMMO[wep_class][2], wep:GetSecondaryAmmoType())
		end
	end
	
	// Keep regular loadout from going (unless specified above)
	return true
end


// Noclip
function saPlayerNoClip(pl, on)
	if event_in_progress == 1 && (!pl:IsAdmin() || event_includes_admins == 1) then
		pl:FancyMsg("NOTIFY_ERROR", "An event is in progress. You may not noclip at this time.", nil)
		return false		
	else
		return server_settings.Bool("sbox_noclip")
	end
end


// Called when a player says something
function saPlayerSay(pl, text, to_all)
	if saShouldCensor(text) then
		pl:PrintMessage(HUD_PRINTTALK, SA_CENSORED_MESSAGE)
		return ""
	end
	
	local text_explode = string.Explode(" ", string.lower(text))
	
	if text_explode[1] == "!vote" && vote_start_time > 0 && pl:GetNWInt("has_voted") == 0 then
		pl:SendLua("saOpenVoteMenu()")
		return ""
	elseif vote_start_time == 0 && text_explode[1] && (text_explode[1] == "!votekick" || text_explode[1] == "!voteban") && text_explode[2] && saGetByUserID(text_explode[2]) then
		vote_pl = saGetByUserID(text_explode[2])
		if vote_pl:IsAdmin() then
			pl:PrintMessage(HUD_PRINTTALK, "You can't votekick/voteban admins.")
			return ""
		end
		if text_explode[1] == "!votekick" then
			vote_type = "votekick"
			vote_end_action = "kickid "..text_explode[2].." \"Vote-kicked!\""
			pl:ConCommand("sa_create_vote 0 \"Kick "..vote_pl:Name().."?\" \"Yes\" \"No\"")
			pl:ConCommand("sa_vote 1\n")
			return ""
		elseif text_explode[1] == "!voteban" then
			vote_type = "voteban"
			vote_end_action = "banid "..SA_VOTEBAN_TIME.." "..text_explode[2].." kick\nwriteid"
			pl:ConCommand("sa_create_vote 0 \"Ban "..vote_pl:Name().."?\" \"Yes\" \"No\"")
			pl:ConCommand("sa_vote 1\n")
			return ""
		end
	end	
end
hook.Add("PlayerSay", "saPlayerSayHook", saPlayerSay)


// Called every time a player spawns
function saPlayerSpawn(pl)
	timer.Destroy("sa_cleanup_" .. pl:UniqueID())
	
	if event_in_progress == 1 then
		pl:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
		
		if !pl.event_spawn_point || !pl.event_spawn_point:IsValid() then
			pl.event_spawn_point = saGetEventSpawn()
		end
		
		if pl.event_spawn_point && pl.event_spawn_point:IsValid() then 
			pl:SetPos(pl.event_spawn_point:GetPos() + Vector(0, 0, 16))
		end
	end
	
	if GAMEMODE.Name == "Sandbox" && SA_SET_TEAMS == 1 then
		if pl:IsAdmin() then
			pl:SetTeam(TEAM_ADMINS)
		else
			pl:SetTeam(TEAM_PLAYERS)
		end
	end
end


// Checks to see if the player can spawn a ragdoll, prop, or effect
function saPlayerSpawnRagdollPropEffect(pl, model)
	return saCanSpawnEnt(pl)
end


// Checks to see if they can spawn vehicle
function saPlayerSpawnVehicle(pl) 
	return saCanSpawnEnt(pl)
end


// Checks to see if they can spawn a SENT
function saPlayerSpawnSENT(pl, name)
	return saCanSpawnEnt(pl)
end


// Checks to see if they can spawn an npc
function saPlayerSpawnNPC(pl, npc_type, equipment) 
	return saCanSpawnEnt(pl)
end 


// Called every frame
function saThink()
	if SA_MESSAGES && #SA_MESSAGES > 0 && SA_MESSAGE_FREQUENCY != 0 && message_start_time == 0 && message_end_time + SA_MESSAGE_FREQUENCY <= CurTime() then
		message_start_time = CurTime()
		message_end_time = 0
		
		if last_message + 1 > #SA_MESSAGES then last_message = 0 end
		last_message = last_message + 1 
		
		umsg.Start("saSetMessageID", RecipientFilter():AddAllPlayers())
		umsg.Long(last_message)
		umsg.End()
	elseif message_start_time != 0 && message_start_time + SA_MESSAGE_TIME <= CurTime() then
		message_end_time = CurTime()
		message_start_time = 0
		
		umsg.Start("saSetMessageID", RecipientFilter():AddAllPlayers())
		umsg.Long(0)
		umsg.End()
	end
	
	// Go through each player every frame
	for _, pl in pairs(player.GetAll()) do
		if vote_start_time > 0 && CurTime() >= (vote_start_time + SA_VOTE_TIME) && pl:GetNWInt("has_voted") == 0 then
			if vote_type == "vote" then
				pl:ConCommand("sa_vote "..math.random(1, #vote_options))
			else
				pl:ConCommand("sa_vote 2\n")
			end
		end
		
		// Bad name
		if saShouldCensor(pl:Name()) then
			game.ConsoleCommand("kickid "..pl:UserID().." \"Please change your name.\"\n")
		end
		
		// High ping
		if pl:Ping() >= SA_PING_LIMIT then
			if pl.pings then
				if pl.ping_start_time + SA_PING_TIME <= CurTime() then
					local total = 0
					for _, ping in pairs(pl.pings) do
						total = total + ping
					end
					
					if total / #pl.pings >= SA_PING_LIMIT then
						game.ConsoleCommand("kickid "..pl:UserID().." \"Average ping too high.\"\n")
					end
					
					pl.pings = nil
					pl.ping_start_time = nil
					pl.next_ping_time = nil
				elseif pl.next_ping_time <= CurTime() then
					table.insert(pl.pings, pl:Ping())
					pl.next_ping_time = CurTime() + 1
				end
			else
				pl.pings = {}
				pl.ping_start_time = CurTime()
				pl.next_ping_time = CurTime() + 1
			end
		end
		
		// Trace!
		if GAMEMODE.IsSandboxDerived then
			local pos = pl:GetShootPos()
			local ang = pl:GetAimVector()
			local trace_data = {}
			trace_data.start = pos
			trace_data.endpos = pos + (ang * 2048)
			trace_data.filter = pl
			local trace = util.TraceLine(trace_data)
			
			// Did we hit something
			umsg.Start("saSetEntityOwnerMsg", pl)
			if trace.HitNonWorld && trace.Entity && trace.Entity:IsValid() then
				local ent = trace.Entity
				
				// Find the owner
				if ent.shared == 1 then
					umsg.String("Shared Entity")
				elseif ent.owner == "World" then
					umsg.String("World Entity")
				elseif ent.owner && player.GetByUniqueID(ent.owner) && player.GetByUniqueID(ent.owner):IsValid() then
					umsg.String("Owned by " .. player.GetByUniqueID(ent.owner):Name())
				end
			else
				umsg.String("")
			end
			umsg.End()
		end
	end	
end
hook.Add("Think", "saThinkHook", saThink)
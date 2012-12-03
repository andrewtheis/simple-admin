// Bans a user
function saBan(pl, command, arguments)
	if !pl:IsAdmin() || !arguments[1] || !arguments[2] then return end
	
	local ply = saGetByUserID(arguments[2])
	if !ply || !ply:IsPlayer() then return end
	
	ply:Ban(arguments[1], arguments[2])
	
	if arguments[3] != "" then
		PrintMessage(HUD_PRINTTALK, Format("%s banned %s from the server (%s).", pl:Name(), ply:Name(), arguments[3]))
	else
		PrintMessage(HUD_PRINTTALK, Format("%s banned %s from the server.", pl:Name(), ply:Name()))
	end
end


// Gets the player needed for cleaning up
function saCleanup(pl, command, arguments)
	if !GAMEMODE.IsSandboxDerived || !pl:IsAdmin() || !arguments[1] then return end
	
	pl_to_cleanup = saGetByUserID(arguments[1])
	if pl_to_cleanup && pl_to_cleanup:IsPlayer() then
		PrintMessage(HUD_PRINTTALK, Format("%s cleaned up everything owned by %s.", pl:Name(), pl_to_cleanup:Name()))
		cleanup.CC_Cleanup(pl_to_cleanup, "gmod_cleanup", "")		
	end
end


// Creates a vote
function saCreateVote(pl, command, arguments)
	if (vote_type == "vote" && !pl:IsAdmin()) || vote_start_time > 0 || !arguments || #arguments < 4 then return end
	
	vote_start_time = CurTime()
	
	// Send to client
	umsg.Start("saSetVoteInfo", RecipientFilter():AddAllPlayers())
		umsg.Short(arguments[1])
		table.remove(arguments, 1)
		
		umsg.String(arguments[1])
		table.remove(arguments, 1)
		
		// Set vote options
		umsg.Long(#arguments)
		vote_options = {}
		for a, vote_option in pairs(arguments) do
			umsg.String(vote_option)
			vote_options[a] = {1, vote_option}
		end
	umsg.End()
	
	// No one has voted
	number_of_votes = 0

	// Reset all player variables
	for _, pl2 in pairs(player.GetAll()) do
		pl2:SetNWInt("has_voted", 0)
	end
	
	// Message the people
	if vote_type == "vote" then
		PrintMessage(HUD_PRINTTALK, Format("%s has started a vote.", pl:Name()))
	else
		PrintMessage(HUD_PRINTTALK, Format("%s has started a %s. Type !vote to bring up the voting menu.", pl:Name(), vote_type))
	end
end


// Starts or ends an event
function saEvent(pl, command, arguments)
	if !GAMEMODE.IsSandboxDerived || !pl:IsAdmin() then return end
	
	// Toggle event mode
	if event_in_progress == 0 then
		event_in_progress = 1
		event_weapons = string.Explode(" ", arguments[1])
		event_includes_admins = tonumber(arguments[2])
		
		// Go through each player
		for _, pl2 in pairs(player.GetAll()) do
			pl2:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
			
			if !pl2:IsAdmin() || event_includes_admins == 1 then
				if pl2:InVehicle() then
					pl2:ExitVehicle()
				elseif pl2:GetMoveType() == 8 then
					pl2:KillSilent()
				end
				
				pl2:Spawn()
			end
			
			pl2:PrintMessage(HUD_PRINTTALK, Format("%s has started an event.", pl:Name()))
		end
		
		// Do console commands
		game.ConsoleCommand("sbox_godmode 0\n")
		game.ConsoleCommand("mp_falldamage 1\n")
	else
		event_in_progress = 0
		event_weapons = {}
		event_spawn_pos = nil
		
		// Do console commands
		game.ConsoleCommand("sbox_godmode 1\n")
		game.ConsoleCommand("mp_falldamage 0\n")
		
		// Go through each player
		for _, pl2 in pairs(player.GetAll()) do
			if !pl2:IsAdmin() || event_includes_admins == 1 then
				saPlayerLoadout(pl2)
			end
			
			pl2:PrintMessage(HUD_PRINTTALK, Format("%s has ended the event.", pl:Name()))
			pl2:SetCollisionGroup(COLLISION_GROUP_PLAYER)
		end
		
		// Set back to normal
		event_includes_admins = 0
	end
end


// Gets the user based on their UserId
function saGetByUserID(user_id)
	for _, pl in pairs(player.GetAll()) do
		if tostring(pl:UserID()) == tostring(user_id) then
			return pl
		end
	end
end


// Returns the spawn posisition of the first found sent_eventspawnpoint
function saGetEventSpawn()	
	for _, sesp in pairs(ents.FindByClass("sent_eventspawnpoint")) do
		if sesp && sesp:IsValid() && sesp:IsInWorld() then
			return sesp
		end
	end
	
	return nil
end


// Checks to see if a player owns the entity
function saIsTheirs(pl, ent)
	if pl && pl:IsValid() && pl:IsPlayer() && ent && ent:IsValid() then
		if ent:IsPlayer() then return false end
		
		// Is it a wheel or something
		if ent.GetPlayer && ent:GetPlayer():IsValid() then
			ent.owner = ent:GetPlayer():UniqueID()
		end
		
		// Part of the world?
		if ent:GetClass() == "worldspawn" then
			ent.owner = "World"
		end
		
		// Make owner if not done so already
		if !ent.owner then
			ent.owner = pl:UniqueID()
			pl:FancyMsg("NOTIFY_GENERIC", "This is now your entity!", ent)
		end
		
		// If it has an owner, see if it is pl
		if ent.owner == pl:UniqueID() || ent.owner == "World" || ent.shared == 1 || pl:IsAdmin() then
			return true
		else
			pl:FancyMsg("NOTIFY_ERROR", "You do not own this entity!", ent)
			return false
		end
	else
		return true
	end
end


// Kicks a player
function saKick(pl, command, arguments)
	if !pl:IsAdmin() || !arguments[1] then return end
	
	local ply = saGetByUserID(arguments[1])
	if !ply || !ply:IsPlayer() then return end
	
	ply:Kick(arguments[2])
	
	if arguments[2] != "" then
		PrintMessage(HUD_PRINTTALK, Format("%s kicked %s from the server (%s).", pl:Name(), ply:Name(), arguments[2]))
	else
		PrintMessage(HUD_PRINTTALK, Format("%s kicked %s from the server.", pl:Name(), ply:Name()))
	end
end


// Runs a rcon command without the need for rcon!
function saRCon(pl, command, arguments)
	if !pl:IsSuperAdmin() || !arguments[1] then return end
	game.ConsoleCommand(arguments[1].."\n")
end


// Shows the rules
function saRules(pl, command, arguments)
	if !pl:IsAdmin() || !arguments[1] then return end
	
	// Get the person to show the rules and if valid show it
	local pl_to_rule = saGetByUserID(arguments[1])
	if pl_to_rule && pl_to_rule:IsPlayer() then
		umsg.Start("saShowRules", pl_to_rule)
		umsg.End()
	end
end


// Sets a vote's end action (server side)
function saSetVoteEndAction(pl, command, arguments)
	if !pl:IsAdmin() || vote_start_time > 0 || !arguments[1] then return end
	vote_end_action = arguments[1]
end


// Checks string for censored words
function saShouldCensor(text)
	local text_lower = string.lower(text)
	local text_lower_explode = string.Explode(" ", text_lower)
	
	// Check for censored words withen entire text
	for _, censored_word_wildcard in pairs(SA_CENSORED_WORDS_WILDCARD) do	
		if string.find(text_lower, censored_word_wildcard) then
			return true
		end
	end
	
	// Check exact censored words
	for _, word in pairs(text_lower_explode) do
		for _, censored_word in pairs(SA_CENSORED_WORDS) do
			if word == censored_word then
				return true
			end
		end
	end
	
	// Otherwise, clean text
	return false
end


// Called when a player spawns a type stuff
function saSpawnedTypeA(pl, model, ent)
	ent.owner = pl:UniqueID()
	ent.shared = 0
end 


// Called when a player spawns b type stuff
function saSpawnedTypeB(pl, ent)
	ent.owner = pl:UniqueID()
	ent.shared = 0
end


// Teleports player A to player B
function saTeleportTo(pl, command, arguments)
	if !pl:IsAdmin() || !arguments[1] || !arguments[2] then return end
	
	local pl_a = saGetByUserID(arguments[1])
	if !pl_a || !pl_a:Alive() then return end
	
	if arguments[2] == "0" then
		pl_a:SetPos(Vector(arguments[3], arguments[4], arguments[5] + 8))
		PrintMessage(HUD_PRINTTALK, Format("%s teleported %s to a target posistion.", pl:Name(), pl_a:Name()))
	else
		local pl_b = saGetByUserID(arguments[2])
		if pl_b && pl_a != pl_b && pl_b:Alive() then
			pl_a:SetPos(pl_b:GetPos())
			pl_a:SetAngles(pl_b:GetAngles())
			PrintMessage(HUD_PRINTTALK, Format("%s teleported %s to %s.", pl:Name(), pl_a:Name(), pl_b:Name()))
		end
	end
end


// Votes for an option
function saVote(pl, command, arguments)
	if !arguments[1] || vote_start_time == 0 || pl:GetNWInt("has_voted") == 1 then return end
	
	// What is their vote?
	local pl_vote = tonumber(arguments[1])
	
	// Add number
	if pl_vote && vote_options[pl_vote][1] then
		vote_options[pl_vote][1] = vote_options[pl_vote][1] + 1
	else
		return
	end
	
	// Set networked information
	pl:SetNWInt("has_voted", 1)
	pl:SendLua("saCloseVoteMenu()")
	number_of_votes = number_of_votes + 1
	
	PrintMessage(HUD_PRINTTALK, Format("%s's vote: %s", pl:Name(), vote_options[pl_vote][2]))
	
	// Are we done?
	if number_of_votes >= #player.GetAll() then
		vote_start_time = 0
		vote_type = "vote"
		
		local first_option = vote_options[1][2]
		
		table.sort(vote_options, function(a, b) return a[1] > b[1] end)
		PrintMessage(HUD_PRINTTALK, Format("Voting complete. The winner is: %s", vote_options[1][2]))
		
		if vote_end_action != "" && first_option == vote_options[1][2] then
			game.ConsoleCommand(vote_end_action.."\n")
		end
	end
end


// Warns a player about their language
function saWarn(pl, command, arguments)
	if !pl:IsAdmin() || !arguments[1] then return end
	
	// Get the player to warn and warn them
	local pl_to_warn = saGetByUserID(arguments[1])
	if pl_to_warn && pl_to_warn:IsPlayer() then
		pl_to_warn:PrintMessage(HUD_PRINTTALK, Format("%s, %s", pl_to_warn:Name(), SA_CENSORED_MESSAGE))
	end
end 
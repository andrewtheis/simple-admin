// Include the needed files
include("sa_config.lua")
include("sa_player_extension.lua")


// Put the two together
table.Add(SA_MESSAGES, SA_RULES)


// Very important peeps
VIP_IDS = {}
local userinfo = util.KeyValuesToTable(file.Read("../settings/users.txt"))
table.Add(VIP_IDS, userinfo.superadmin)
table.Add(VIP_IDS, userinfo.admin)
table.Add(VIP_IDS, userinfo.vip)


// Called when the server initializes
function saInitialize()
	if SERVER then
		event_in_progress = 0
		event_includes_admins = 0
		event_weapons = {}
		
		message_end_time = 0
		message_start_time = 0
		message_id = 0
		last_message = 0
		
		used_reserved_slots = 0
		
		vote_start_time = 0
		vote_type = "vote"
		vote_end_action = ""
		
		if GAMEMODE.IsSandboxDerived then
			hook.Add("CanPlayerEnterVehicle", "saCanEnterHook", saCanEnter)
			hook.Add("CanTool", "saCanToolHook", saCanTool)
			
			hook.Add("GravGunPunt", "saGravGunPuntHook", saCanPickup)
			hook.Add("GravGunPickupAllowed", "saGravGunPickupAllowedHook", saCanPickup)
			
			hook.Add("InitPostEntity", "saInitPostEntityHook", saInitPostEntity)
			
			hook.Add("OnNPCKilled", "saOnNPCKilled", saOnNPCKilled)
			hook.Add("OnPhysgunReload", "saCanPhysgunReloadHook", saCanPhysgunReload)
			hook.Add("PhysgunPickup", "saPhysgunPickupHook", saCanPickup)
			
			hook.Add("PlayerCanPickupWeapon", "saPlayerCanPickupWeaponHook", saPlayerCanPickupWeapon)
			hook.Add("PlayerLoadout", "saPlayerLoadoutHook", saPlayerLoadout)
			hook.Add("PlayerNoClip", "saPlayerNoClipHook", saPlayerNoClip)
			hook.Add("PlayerSpawn", "saPlayerSpawnHook", saPlayerSpawn)
			
			hook.Add("PlayerSpawnRagdoll", "saSpawnRagdollHook", saPlayerSpawnRagdollPropEffect)
			hook.Add("PlayerSpawnProp", "saSpawnPropHook", saPlayerSpawnRagdollPropEffect)
			hook.Add("PlayerSpawnEffect", "saSpawnEffectHook", saPlayerSpawnRagdollPropEffect)
			
			hook.Add("PlayerSpawnVehicle", "saSpawnVehicleHook", saPlayerSpawnVehicle)
			hook.Add("PlayerSpawnNPC", "saSpawnNPCHook", saPlayerSpawnNPC)
			hook.Add("PlayerSpawnSENT", "saSpawnSENTHook", saPlayerSpawnSENT)
			
			hook.Add("PlayerSpawnedRagdoll", "saSpawnedRagdollHook", saSpawnedTypeA)
			hook.Add("PlayerSpawnedProp", "saSpawnedPropHook", saSpawnedTypeA)
			hook.Add("PlayerSpawnedEffect", "saSpawnedEffectHook", saSpawnedTypeA)
			
			hook.Add("PlayerSpawnedVehicle", "saSpawnedVehicleHook", saSpawnedTypeB)
			hook.Add("PlayerSpawnedNPC", "saSpawnedNPCHook", saSpawnedTypeB)
			hook.Add("PlayerSpawnedSENT", "saSpawnedSENTHook", saSpawnedTypeB)
			
			hook.Add("PlayerUse", "saCanUseHook", saCanUse)
		end
	end
	
	// Teams
	if GAMEMODE.Name == "Sandbox" && SA_SET_TEAMS == 1 then
		TEAM_ADMINS = 1
		team.SetUp(TEAM_ADMINS, "Admins", Color(30, 200, 50, 255))
		
		TEAM_PLAYERS = 2
		team.SetUp(TEAM_PLAYERS, "Players",  Color(100, 150, 245, 255))
	end
end
hook.Add("Initialize", "saInitializeHook", saInitialize)
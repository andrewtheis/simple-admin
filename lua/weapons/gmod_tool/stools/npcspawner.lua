// Setup some basic information for the tool
TOOL.Category = "Construction"
TOOL.Name = "#NPC Spawner"
TOOL.Command = nil
TOOL.ConfigName = ""


// Create initial client variables
TOOL.ClientConVar["npc"] = "npc_zombie"
TOOL.ClientConVar["weapon"] = "weapon_357"
TOOL.ClientConVar["togglekey"] = "5"
TOOL.ClientConVar["delay"] = "4"
TOOL.ClientConVar["maximum"] = "5"
TOOL.ClientConVar["healthmul"] = "1"
TOOL.ClientConVar["spawnheight"] = "16"
TOOL.ClientConVar["spawnradius"] = "16"
TOOL.ClientConVar["nocollide"] = "1"
TOOL.ClientConVar["autoremove"] = "1"
TOOL.ClientConVar["enabled"] = "1"



// Add default language translation
if CLIENT then
	language.Add("Tool_npcspawner_name", "NPC Spawner")
	language.Add("Tool_npcspawner_desc", "Creates an NPC spawn platform.")
	language.Add("Tool_npcspawner_0", "Left-click to create spawn platform || update existing spawn platform.")
	language.Add("Undone_npc spawner", "Undone NPC Spawner")
	language.Add("Cleanup_sent_npcspawners", "NPC Spawners")
	language.Add("Cleaned_sent_npcspawners", "Cleaned up all NPC Spawners")
	language.Add("SBoxLimit_npcspawners", "You've hit the NPC spawner limit!")
end


// Allows the cleanup of all of npc spawners
cleanup.Register("sent_npcspawners")


// Setup server stuff
if SERVER then
	if !ConVarExists("sbox_maxnpcsspawners") then CreateConVar("sbox_maxnpcspawners", 5, FCVAR_NOTIFY) end
	
	// Create duplicator functionality
	function MakeNPCSpawner(pl, Pos, Ang, spawnheight, spawnradius, delay, npc, weapon, maximum, enabled, autoremove, healthmul, nocollide, togglekey)
		if !pl:CheckLimit("npcspawners") then return nil end
		
		local ent = ents.Create("sent_npcspawner")
		ent:SetKeyValue("ply", pl:EntIndex())
		ent:SetKeyValue("spawnheight", spawnheight)
		ent:SetKeyValue("spawnradius", spawnradius)
		ent:SetKeyValue("delay", delay)
		ent:SetKeyValue("npc", npc)
		ent:SetKeyValue("weapon", weapon)
		ent:SetKeyValue("maximum", maximum)
		ent:SetKeyValue("enabled", enabled)
		ent:SetKeyValue("autoremove", autoremove)
		ent:SetKeyValue("healthmul", healthmul)
		ent:SetKeyValue("nocollide", nocollide)
		ent:SetKeyValue("togglekey", togglekey)
		ent:SetPos(Pos)
		ent:SetAngles(Ang)
		ent:Spawn()
		ent:Activate()
		ent.owner = pl:UniqueID()
		ent:SetPlayer(pl)
		
		pl:AddCleanup("sent_npcspawners", ent)
		pl:AddCount("npcspawners", ent)
		
		DoPropSpawnedEffect(ent) 
		
		return ent
	end
	duplicator.RegisterEntityClass("sent_npcspawner", MakeNPCSpawner, "Pos", "Ang", "spawnheight", "spawnradius", "delay", "npc", "weapon", "maximum", "enabled", "autoremove", "healthmul", "nocollide", "togglekey")
end


// Called when player left clicks with tool
function TOOL:LeftClick(trace)
	if !trace.HitPos || trace.Entity:IsPlayer() || (SA_NPC_SPAWNER_ADMIN_ONLY == 1 && !self.Weapon:GetOwner():IsAdmin()) then return false end
	if CLIENT then return true end
	
	// Easier for stuff
	pl = self.Weapon:GetOwner()
	
	// Update the spawner
	if trace.Entity:GetClass() == "sent_npcspawner" then
		local ent = trace.Entity
		ent:SetKeyValue("ply", pl:EntIndex())
		ent:SetKeyValue("spawnheight", math.min(self:GetClientInfo("spawnheight"), 128))
		ent:SetKeyValue("spawnradius", math.min(self:GetClientInfo("spawnradius"), 128))
		ent:SetKeyValue("delay", math.max(self:GetClientInfo("delay"), 0.5))
		ent:SetKeyValue("npc", self:GetClientInfo("npc"))
		ent:SetKeyValue("weapon", self:GetClientInfo("weapon"))
		ent:SetKeyValue("maximum", math.min(self:GetClientInfo("maximum"), 25))
		ent:SetKeyValue("enabled", self:GetClientInfo("enabled"))
		ent:SetKeyValue("autoremove", self:GetClientInfo ("autoremove"))
		ent:SetKeyValue("healthmul", math.min(self:GetClientInfo("healthmul"), 10))
		ent:SetKeyValue("nocollide", self:GetClientInfo ("nocollide"))
		ent:SetKeyValue("togglekey", self:GetClientInfo("togglekey"))
		return true
	end
	
	// Otherwise make a new one!
	local ent = MakeNPCSpawner(
		pl,
		trace.HitPos + Vector(0, 0, 15),
		Angle(0.5, -0.5, -1),
		math.min(self:GetClientInfo("spawnheight"), 128),
		math.min(self:GetClientInfo("spawnradius"), 128),
		math.max(self:GetClientInfo("delay"), 0.5),
		self:GetClientInfo("npc"),
		self:GetClientInfo("weapon"),
		math.min(self:GetClientInfo("maximum"), 25),
		self:GetClientInfo("enabled"),
		self:GetClientInfo("autoremove"),
		math.min(self:GetClientInfo("healthmul"), 10),
		self:GetClientInfo ("nocollide"),
		self:GetClientInfo("togglekey")
	)
	
	// Undo
	undo.Create("NPC Spawner")
	undo.AddEntity(ent)
	undo.SetPlayer(pl)
	undo.Finish()
	
	// Return true
	return true
end


// Called when the player right clicks with tool
function TOOL:RightClick (trace)
	return self:LeftClick(trace)
end


// Called when cpanel needs to be build
function TOOL.BuildCPanel(cpanel)
	cpanel:AddControl("Header", {Text = "#Tool_npcspawner_name", Description = "#Tool_npcspawner_desc"}) 
	
	if SA_NPC_SPAWNER_ADMIN_ONLY == 1 && !LocalPlayer():IsAdmin() then 
		cpanel:AddControl("Label", {Text = "This tool is for admins only.", Description = ""})
		return 
	end
	
	cpanel:AddControl("ComboBox", {
		Label = "#Presets",
		MenuButton = 1,
		Folder = "npcspawner",
		Options = {},
		CVars =
		{
			[0] = "npcspawner_npc",
			[1] = "npcspawner_weapon",
			[2] = "npcspawner_togglekey",
			[3] = "npcspawner_delay",
			[4] = "npcspawner_maximum",
			[5] = "npcspawner_healthmul",
			[6] = "npcspawner_spawnheight",
			[7] = "npcspawner_spawnradius",
			[8] = "npcspawner_nocollide",
			[9] = "npcspawner_autoremove",
			[10] = "npcspawner_enabled",
		}
	})
	
	// NPC selection
	npc_cb = {}
	npc_cb.Label = "NPC"
	npc_cb.MenuButton = 0
	npc_cb.Options = {} 
	npc_cb.Command = "npcspawner_npc"
	for _, npc in pairs(list.Get("NPC")) do
		npc_cb.Options[npc.Name] = {npcspawner_npc = npc.Class}
	end
	cpanel:AddControl("ComboBox", npc_cb)
	
	// NPC weapon selection
	wep_cb = {}
	wep_cb.Label = "Weapon"
	wep_cb.MenuButton = 0
	wep_cb.Options = {}
	wep_cb.Command = "npcspawner_weapon"
	for classname, nicename in pairs(list.Get("NPCWeapons")) do
		wep_cb.Options[nicename] = {npcspawner_weapon = classname}
	end
	cpanel:AddControl("ComboBox", wep_cb)
	
	// Numpad
	cpanel:AddControl("Numpad", {Label = "Toggle On/Off", Command = "npcspawner_togglekey", ButtonSize = 22})
	
	// Sliders
	cpanel:AddControl("Slider", {Label = "Spawn Delay", Type = "Float", Min = 0.5, Max	= 60, Command = "npcspawner_delay", Description = "The delay between each NPC spawn."})
	cpanel:AddControl("Slider", {Label = "Maximum In Action Simultaneously", Type = "Integer", Min = 1, Max = 25, Command = "npcspawner_maximum", Description = "The maximum NPCs allowed from the spanwer at one time."})
	cpanel:AddControl("Slider", {Label = "Health Multiplier", Type = "Float", Min = 0.5, Max = 10, Command = "npcspawner_healthmul", Description = "The multiplier applied to the health of all NPCs on spawn."})
	cpanel:AddControl("Slider", {Label = "Spawn Height Offset", Type = "Float", Min = 8, Max = 128, Command = "npcspawner_spawnheight", Description = "Height above spawn platform NPCs originate from."})
	cpanel:AddControl("Slider", {Label = "Spawn Radius", Type = "Float", Min = 0, Max = 128, Command = "npcspawner_spawnradius", Description = "Area (radius) around the spawner in which NPCs will spawn."})
	
	// Checkboxes
	cpanel:AddControl("Checkbox", {Label = "No Collision Between Spawned NPCs", Command = "npcspawner_nocollide", Description = "If this is checked, NPCs will not collide with any other NPCs spawned with this option on. This helps prevent stacking in the spawn area"})
	cpanel:AddControl("Checkbox", {Label = "Remove NPCs When Spawner Destroyed", Command = "npcspawner_autoremove", Description = "If this is checked, all NPCs spawned by a platform will be removed with the platform."})	
	cpanel:AddControl("Checkbox", {Label = "Spawn Enabled", Command = "npcspawner_enabled", Description = "If this is checked, spawned || updated platforms will be turned on."})
end


// Called when player presses reload
function TOOL:Reload (trace)
end


// Called every frame
function TOOL:Think()
end
// Send required filed to client
AddCSLuaFile("shared.lua")


// Include needed files
include("shared.lua")


// Precache the models
util.PrecacheModel(ENT.Model2)


// Setup initial entity vars
ENT.npc = "npc_combine_s"
ENT.weapon = "weapon_smg1"
ENT.delay = 5
ENT.maximum = 5
ENT.spawnheight = 16
ENT.spawnradius = 16
ENT.autoremove = 1
ENT.healthmul = 1
ENT.enabled = 0
ENT.togglekey = 5


// Called when entity initializes
function ENT:Initialize()
	self:SetModel(self.Model2)
	
	// Setup physics
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then phys:Wake() end
	
	// Set vars again?
	self.last_spawn = CurTime()
	self.spawned_npcs = {}
	self.last_model = 2
	
	// Toggles spawner
	function toggleSpawner(pl, ent, state)
		if ent.enabled == 0 then
			ent.enabled = 1
		else
			ent.enabled = 0
		end
	end
	
	// Register the numpad
	numpad.Register("npcSpawnerToggle", toggleSpawner)
	numpad.OnDown(player.GetByID(tonumber(self.ply)), self.togglekey, "npcSpawnerToggle", self)
end


// Called every frame
function ENT:Think()
	if CLIENT then return end
	
	self:SetOverlayText("NPC: "..self.npc.."\nWeapon: "..self.weapon)
	
	// Are we enabled or not?
	if self.enabled == 1 then
		self:SetColor(0, 255, 0, 255)
	elseif self.enabled == 0 then
		self:SetColor(255, 0, 0, 255)
		return
	end
	
	// Check to see if npc's are alive or not
	for a, npc in pairs(self.spawned_npcs) do
		if !npc:IsValid() then
			table.remove(self.spawned_npcs, a)
		end
	end
	
	// Check to see if we have too many NPC's
	if #self.spawned_npcs >= self.maximum && self.last_model == 2 then
		self:SetModel(self.Model1)
		self.last_model = 1
	elseif #self.spawned_npcs < self.maximum && self.last_model == 1 then
		self:SetModel(self.Model2)
		self.last_model = 2
	end
	
	// Time to spawn again?
	if #self.spawned_npcs < self.maximum && self.last_spawn + self.delay < CurTime() && self.enabled == 1 then
		npc = ents.Create(self.npc)
		
		if !npc || !npc:IsValid() then return end
		
		spawnpos = self:GetPos() + Vector((math.random() - 0.5) * self.spawnradius * 2, (math.random () - 0.5) * self.spawnradius * 2, self.spawnheight)
		
		npc:SetPos(spawnpos)
		npc:SetKeyValue("additionalequipment", self.weapon)
		npc:Spawn()
		
		// Set maxhealth
		local npc_health = npc:GetMaxHealth()
		npc:SetMaxHealth (npc_health * self.healthmul)
		npc:SetHealth (npc_health * self.healthmul)
		
		// Setup nocollide
		if self.nocollide == 1 then
			npc:SetCollisionGroup(3)
		end
		
		// Nobody owns this
		npc.owner = "World"
		
		// Add to table && update last spawn
		table.insert(self.spawned_npcs, npc)
		self.last_spawn = CurTime()
	end
end


// Called when a player uses the entity
function ENT:Use(activator, caller)
	if self.enabled == 0 then
		self.enabled = 1
	else
		self.enabled = 0
	end
end


// Called when you use SetKeyValue
function ENT:KeyValue(key, value)
	self[key] = tonumber(value) || value
	
	// Update delay
	if key == "delay" then
		self.last_spawn = CurTime()
	end
end


// Called when you remove the entity
function ENT:OnRemove()
	if self.autoremove == 1 then
		for _, npc in pairs (self.spawned_npcs) do
			if npc && npc:IsValid() then npc:Remove() end
		end
	end
end
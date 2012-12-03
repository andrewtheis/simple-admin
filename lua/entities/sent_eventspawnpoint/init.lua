// Send required filed to client
AddCSLuaFile("shared.lua")
resource.AddFile("materials/vgui/entities/sent_eventspawnpoint.vtf")
resource.AddFile("materials/vgui/entities/sent_eventspawnpoint.vmt")


// Include needed files
include("shared.lua")


// Precache the model
util.PrecacheModel("models/props_combine/combine_mine01.mdl")


// Called when entity initializes
function ENT:Initialize()
	self:SetModel("models/props_combine/combine_mine01.mdl")
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetOverlayText("Event Spawn Point")
	
	local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then phys:Wake() end
end


// Called when someone uses me
function ENT:Use(activator, caller)
	if activator:IsPlayer() then
		activator.event_spawn_point = self
		activator:FancyMsg("NOTIFY_GENERIC", "Event spawn point set!", self)
	end
end


// Called to spawn
function ENT:SpawnFunction(pl, trace)  
 	if !trace.Hit then return end 
 	
 	local spawn_pos = trace.HitPos + trace.HitNormal * 10 
 	
 	local ent = ents.Create("sent_eventspawnpoint")
	ent:SetPos(spawn_pos) 
 	ent:Spawn()
 	ent:Activate()
	ent.owner = pl
	ent:SetPlayer(pl)
	
	return ent
end
// Intial tool settings
TOOL.Category = "Construction"
TOOL.Name = "#Stacker"
TOOL.Command = nil
TOOL.ConfigName	= ""


// Initial stacker settings
TOOL.ClientConVar["mode"] = "1"
TOOL.ClientConVar["dir"] = "1"
TOOL.ClientConVar["count"] = "1"
TOOL.ClientConVar["offsetx"] = "0"
TOOL.ClientConVar["offsety"] = "0"
TOOL.ClientConVar["offsetz"] = "0"
TOOL.ClientConVar["rotp"] = "0"
TOOL.ClientConVar["roty"] = "0"
TOOL.ClientConVar["rotr"] = "0"
TOOL.ClientConVar["freeze"] = "0"
TOOL.ClientConVar["nocollide"] = "0"
TOOL.ClientConVar["recalc"] = "0"
TOOL.ClientConVar["weld"] = "0"


// Add default language translation
if CLIENT then
	language.Add("Tool_stacker_name", "Stacker")
	language.Add("Tool_stacker_desc", "Stack props easily.")
	language.Add("Tool_stacker_0", "Left-click to stack the prop you are looking at.")
	language.Add("Undone_stacker", "Undone Stack")
end


// Executed when player left clicks with this tool
function TOOL:LeftClick(trace)
	if !trace.Entity || !trace.Entity:IsValid() || trace.Entity:GetClass() != "prop_physics" then return false end
	if CLIENT then return true end
	
	// Get the client data
	local freeze = self:GetClientNumber("freeze") == 1
	local weld = self:GetClientNumber("weld") == 1
	local nocollide = self:GetClientNumber("nocollide") == 1
	local mode = self:GetClientNumber("mode")
	local dir = self:GetClientNumber("dir")
	local count = self:GetClientNumber("count")
	local offsetx = self:GetClientNumber("offsetx")
	local offsety = self:GetClientNumber("offsety")
	local offsetz = self:GetClientNumber("offsetz")
	local rotp = self:GetClientNumber("rotp")
	local roty = self:GetClientNumber("roty")
	local rotr = self:GetClientNumber("rotr")
	local recalc = self:GetClientNumber("recalc") == 1
	local offset = Vector(offsetx, offsety, offsetz)
	local rot = Angle(rotp, roty, rotr)
	
	// Setup pl && entity
	local pl = self:GetOwner()
	local ent = trace.Entity
	
	// New vec, ang && last ent
	local newvec = ent:GetPos()
	local newang = ent:GetAngles()
	local lastent = ent
	
	// Setup new undo
	undo.Create("Stacker")
	
	// Main for loop
	for i=1, count, 1 do
		if !self:GetSWEP():CheckLimit("props") then break end
		
		// Calculate the new posistion if it is the first time
		if i == 1 || (mode == 2 && recalc == true) then
			stackdir, height, thisoffset = self:StackerCalcPos(lastent, mode, dir, offset)
		end
		
		// New vector information
		newvec = newvec + stackdir * height + thisoffset
		newang = newang + rot
		
		// Find out if there is an entity on this spot
		local entlist = ents.FindInSphere(newvec,1)
		local bFound = false
		for k, v in pairs(entlist) do
			if v:IsValid() && v != lastent && v:GetClass() == "prop_physics" && v:GetPos() == newvec && v != self.GhostEntity then
				bFound = true
			end
		end
		if bFound then break end
		
		// Create the new entity
		newent = ents.Create("prop_physics")
		newent:SetModel(ent:GetModel())
		newent:SetColor(ent:GetColor())
		newent:SetSkin(ent:GetSkin())
		newent:SetPos(newvec)
		newent:SetAngles(newang)
		newent:Spawn()
		
		// Freeze it?
		if freeze then 
			newent:GetPhysicsObject():EnableMotion(false)
		end
		
		// Weld new ent?
		if weld then
			local weldent = constraint.Weld(lastent, newent, 0, 0, 0)
			undo.AddEntity(weldent)
		end
		
		// If new ent needs to nocollide
		if nocollide then
			local nocollideent = constraint.NoCollide(lastent, newent, 0, 0)
			undo.AddEntity(nocollideent)
		end
		
		// Set the new owner
		newent.owner = pl:UniqueID()
		
		// Setup last minute stuff
		lastent = newent
		undo.AddEntity(newent)
		pl:AddCount("props", newent)
		pl:AddCleanup("props", newent)
	end
	
	// Set the undo pl && finish undo
	undo.SetPlayer(pl)
	undo.Finish()
	
	// We can execute this
	return true
end


// Function to calculate the posistion
function TOOL:StackerCalcPos(lastent, mode, dir, offset)
	local forward = Vector(1, 0, 0):Angle()
	local pos = lastent:GetPos()
	local ang = lastent:GetAngles()
	local lower, upper = lastent:WorldSpaceAABB()
	local glower = lastent:OBBMins()
	local gupper = lastent:OBBMaxs()
	local stackdir = Vector(0, 0, 1)
	local height = math.abs(upper.z - lower.z)

	// Decide how to calculate based on the mode
	if mode == 1 then
		if dir == 1 then
			stackdir = forward:Up()
			height = math.abs(upper.z - lower.z)
		elseif dir == 2 then
			stackdir = forward:Up() * -1
			height = math.abs(upper.z - lower.z)
		elseif dir == 3 then
			stackdir = forward:Forward()
			height = math.abs(upper.x - lower.x)
		elseif dir == 4 then
			stackdir = forward:Forward() * -1
			height = math.abs(upper.x - lower.x)
		elseif dir == 5 then
			stackdir = forward:Right()
			height = math.abs(upper.y - lower.y)
		elseif dir == 6 then
			stackdir = forward:Right() * -1
			height = math.abs(upper.y - lower.y)
		end
	elseif mode == 2 then
		forward = ang
		if dir == 1 then
			stackdir = forward:Up()
			offset = forward:Up() * offset.X + forward:Forward() * -1 * offset.Z + forward:Right() * offset.Y
			height = math.abs(gupper.z - glower.z)
		elseif dir == 2 then
			stackdir = forward:Up() * -1
			offset = forward:Up() * -1 * offset.X + forward:Forward() * offset.Z + forward:Right() * offset.Y
			height = math.abs(gupper.z - glower.z)
		elseif dir == 3 then
			stackdir = forward:Forward()
			offset = forward:Forward() * offset.X + forward:Up() * offset.Z + forward:Right() * offset.Y
			height = math.abs(gupper.x - glower.x)
		elseif dir == 4 then
			stackdir = forward:Forward() * -1
			offset = forward:Forward() * -1 * offset.X + forward:Up() * offset.Z + forward:Right() * -1 * offset.Y
			height = math.abs(gupper.x - glower.x)
		elseif dir == 5 then
			stackdir = forward:Right()
			offset = forward:Right() * offset.X + forward:Up() * offset.Z + forward:Forward() * -1 * offset.Y
			height = math.abs(gupper.y - glower.y)
		elseif dir == 6 then
			stackdir = forward:Right() * -1
			offset = forward:Right() * -1 * offset.X + forward:Up() * offset.Z + forward:Forward() * offset.Y
			height = math.abs(gupper.y - glower.y)
		end
	end
	
	// Return the values
	return stackdir, height, offset
end


// When the player right clicks (does the same as left click)
function TOOL:RightClick(trace)
	return self:LeftClick(trace)
end


// Build the cpanel
function TOOL.BuildCPanel(cpanel)
	cpanel:AddControl("Header", {Text = "#Tool_stacker_name", Description = "#Tool_stacker_desc"})
	
	cpanel:AddControl("ComboBox", {
		Label = "#Presets",
		MenuButton = 1,
		Folder = "stacker",
		Options = {},
		CVars =
		{
			[0] = "stacker_mode",
			[1] = "stacker_dir",
			[2] = "stacker_count",
			[4] = "stacker_offsetx",
			[5] = "stacker_offsety",
			[6] = "stacker_offsetz",
			[7] = "stacker_rotp",
			[8] = "stacker_roty",
			[9] = "stacker_rotr",
			[10] = "stacker_freeze",
			[11] = "stacker_nocollide",
			[12] = "stacker_recalc",
			[13] = "stacker_weld"
		}
	})
	
	// Relative to selection
	local params = {Label = "Relative To:", MenuButton = "0", Command = "stacker_mode", Options = {}}
	params.Options["World"] = {stacker_mode = "1"}
	params.Options["Prop"] = {stacker_mode = "2"}
	cpanel:AddControl("ComboBox", params)
	
	// Stack direction selection
	local params = {Label = "Stack Direction", MenuButton = "0", Command = "stacker_dir", Options = {}}
	params.Options["Up"] = {stacker_dir = "1"}
	params.Options["Down"] = {stacker_dir = "2"}
	params.Options["Forward"] = {stacker_dir = "3"}
	params.Options["Back"] = {stacker_dir = "4"}
	params.Options["Right"] = {stacker_dir = "5"}
	params.Options["Left"] = {stacker_dir = "6"}
	cpanel:AddControl("ComboBox", params)
	
	// Add the rest of the controls
	cpanel:AddControl("Slider", {Label = "Count", Type = "Integer", Min	= 1, Max = 25, Command = "stacker_count", Description = "How many props to stack."})
	cpanel:AddControl("Slider", {Label = "Offset X (Forward / Back)", Type = "Float", Min= -1000, Max = 1000, Command = "stacker_offsetx"})
	cpanel:AddControl("Slider", {Label = "Offset Y (Right / Left)", Type = "Float", Min = -1000, Max = 1000, Command = "stacker_offsety"})
	cpanel:AddControl("Slider", {Label = "Offset Z (Up / Down)", Type = "Float", Min = -1000, Max = 1000, Command = "stacker_offsetz"})
	cpanel:AddControl("Slider", {Label = "Rotate Pitch", Type = "Float", Min = -180, Max = 180, Command = "stacker_rotp"})
	cpanel:AddControl("Slider", {Label = "Rotate Yaw", Type = "Float", Min = -180, Max = 180, Command = "stacker_roty"})
	cpanel:AddControl("Slider", {Label = "Rotate Roll", Type = "Float", Min = -180, Max = 180, Command = "stacker_rotr"})
	
	cpanel:AddControl("Checkbox", {Label = "Freeze", Command = "stacker_freeze"})
	cpanel:AddControl("Checkbox", {Label = "No Collide", Command = "stacker_nocollide"})
	cpanel:AddControl("Checkbox", {Label = "Stack Relative", Command = "stacker_recalc", Description = "If this is checked, each item in the stack will be stacked relative to the previous item in the stack. This allows you to create curved stacks."})
	cpanel:AddControl("Checkbox", {Label = "Weld", Command = "stacker_weld"})
end


// Updates the ghost stack
function TOOL:UpdateGhostStack(ghost, pl, ent)
	if !ent || !ghost || !ent:IsValid() || !ghost:IsValid() then return end
	
	// Get the client variables
	local mode = self:GetClientNumber("mode")
	local dir = self:GetClientNumber("dir")
	local offsetx = self:GetClientNumber("offsetx")
	local offsety = self:GetClientNumber("offsety")
	local offsetz = self:GetClientNumber("offsetz")
	local rotp = self:GetClientNumber("rotp")
	local roty = self:GetClientNumber("roty")
	local rotr = self:GetClientNumber("rotr")
	local offset = Vector(offsetx, offsety, offsetz)
	local rot = Angle(rotp, roty, rotr)	
	
	// Setup stackdir and new vec/ang
	local stackdir, height, thisoffset = self:StackerCalcPos(ent, mode, dir, offset)
	local newvec = ent:GetPos() + stackdir * height + thisoffset
	local newang = ent:GetAngles() + rot
	
	// Setup the ghost
	ghost:SetAngles(newang)
	ghost:SetPos(newvec)
	ghost:SetNoDraw(false)
end


// Called every frame
function TOOL:Think()
	local pl = self:GetOwner()
	local tr = utilx.GetPlayerTrace(pl, pl:GetCursorAimVector())
	local trace = util.TraceLine(tr)
	
	// We hit something?
	if trace.Hit then
		local newent = trace.Entity
		
		// Update the ghost/create it
		if newent:IsValid() && newent:GetClass() == "prop_physics" && (newent != self.lastent || !self.GhostEntity) then
			self:MakeGhostEntity(newent:GetModel(), Vector(0, 0, 0), Angle(0,0,0))
			self.lastent = newent
		end
		
		// Release ghost entity
		if (!self.lastent || !self.lastent:IsValid()) && self.GhostEntity then
			self:ReleaseGhostEntity()
		end
	end

	if self.lastent != nil && self.lastent:IsValid() then
		self:UpdateGhostStack(self.GhostEntity, pl, self.lastent)
	end
end 
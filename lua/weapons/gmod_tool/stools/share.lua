// Setup some basic information for the tool
TOOL.Category = "Construction"
TOOL.Name = "#Share"
TOOL.Command = nil
TOOL.ConfigName = ""


// Add default language translation
if CLIENT then
	language.Add("Tool_share_name", "Share")
	language.Add("Tool_share_desc", "Shares an entity you own with everyone.")
	language.Add("Tool_share_0", "Left-click to share an entity. Right-click to unshare it.")
end


// Called when player left clicks
function TOOL:LeftClick(trace)
	ent = trace.Entity
	
	// Can we continue
	if !ent || !ent:IsValid() then return false end
	if CLIENT then return true end
	
	// Share the entity
	ent.shared = 1
	return true
end


// Called when player right clicks
function TOOL:RightClick(trace)
	ent = trace.Entity
	
	// Can we continue?
	if !ent || !ent:IsValid() then return false end
	if CLIENT then return true end
	
	// Un-share the entity
	ent.shared = 0
	return true
end


// What our tool will look like in menu
function TOOL.BuildCPanel(cpanel)
	cpanel:AddControl("Header", {Text = "#Tool_share_name", Description = "#Tool_share_desc"})
end 
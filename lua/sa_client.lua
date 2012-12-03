// Include the needed files
include("sa_menu.lua")
include("sa_shared.lua")


// Called every frame to draw client side stuff
function saHUDPaint()
	ctr_x = ScrW() / 2
	ctr_y = ScrH() / 2
	
	// Draw messages
	if message_id && message_id != 0 then
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(0, 0, ScrW(), 25)
		draw.DrawText(SA_MESSAGES[message_id], "sa_arial", ctr_x, 5, Color(255, 255, 255, 255), 1)
	end
	
	// Draw entity owner
	if entity_owner_msg && entity_owner_msg != "" then
		surface.SetFont("sa_arial")
		local tw, th = surface.GetTextSize(entity_owner_msg)
		
		draw.RoundedBox(8, ScrW() - (35 + tw), 20, tw + 10, 25, Color(0, 0, 0, 75))
		draw.DrawText(entity_owner_msg, "sa_arial", ScrW() - 31, 24, Color(255, 220, 0, 255), 2)
	end
end
hook.Add("HUDPaint", "saHUDPaintHook", saHUDPaint)


// Called when we init
function saInitializeClient()
	surface.CreateFont("Arial", 16, 400, true, false, "sa_arial")
	surface.CreateFont("Impact", 36, 400, true, false, "sa_impact")
	
	entity_owner_msg = ""
	message_id = 0
end
hook.Add("Initialize", "saInitializeClient", saInitializeClient)


// Show rules
function saShowRules(um)	
	local rules = "An admin has decided to remind you of the server rules:\n"
	
	for b, rule in pairs(SA_RULES) do
		rules = rules .. "- " .. rule .. "\n"
	end
	
	local rules_menu = vgui.Create("DFrame")
	local rules_panel = vgui.Create("DPanel", rules_menu)
	local rules_label = vgui.Create("DLabel", rules_panel)
	
	rules_label:SetText(rules)
	rules_label:SetTextColor(color_black)
	rules_label:SizeToContents()
	rules_label:SetPos(5, 5)
	
	local w, h = rules_label:GetSize()
	rules_menu:SetSize(w + 20, h + 30)
	
	rules_panel:StretchToParent(5, 28, 5, 5)
	
	rules_menu:SetTitle("Server Rules")
	rules_menu:Center()
	rules_menu:MakePopup()
end
usermessage.Hook("saShowRules", saShowRules)


// Get entity owner
function saSetEntityOwnerMsg(um)
	entity_owner_msg = um:ReadString()
end
usermessage.Hook("saSetEntityOwnerMsg", saSetEntityOwnerMsg)


// Get message id
function saSetMessageID(um)
	message_id = um:ReadLong()
end
usermessage.Hook("saSetMessageID", saSetMessageID)


// Get voting options
function saSetVoteInfo(um)
	open_menu = um:ReadShort()
	vote_question = um:ReadString()
	
	vote_options = {}
	for a = 1, um:ReadLong() do
		vote_options[a] = um:ReadString()
	end
	
	if open_menu == 1 then
		saOpenVoteMenu()
	end
end
usermessage.Hook("saSetVoteInfo", saSetVoteInfo)


// Simple menu for voting
function saOpenVoteMenu()
	saCloseVoteMenu()
	
	surface.SetFont("sa_arial")
	sa_vote_menu = vgui.Create("DFrame")
	sa_vote_menu:SetPos(50, 350)
	local x, y = surface.GetTextSize(vote_question)
	sa_vote_menu:SetSize(x + 20, 30 + (#vote_options * 25))
	sa_vote_menu:SetTitle(vote_question)
	sa_vote_menu:MakePopup()
	
	// Add options
	for a, vote_option in pairs(vote_options) do
		local sa_vote_btn = vgui.Create("DButton")
		sa_vote_btn:SetParent(sa_vote_menu)
		sa_vote_btn:SetText(vote_option)
		sa_vote_btn:SetPos(5, 30 + ((a - 1) * 25))
		sa_vote_btn:SetSize(x + 10, 20)
		sa_vote_btn.DoClick = function()
			LocalPlayer():ConCommand("sa_vote "..a.."\n")
		end
	end
end


// Closes simple menu
function saCloseVoteMenu()
	if sa_vote_menu then
		sa_vote_menu:Remove()
		sa_vote_menu = nil
	end
end
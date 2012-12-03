local sa_ban_time = CreateClientConVar("sa_ban_time", 0, true, true)
local sa_event_include_admins = CreateClientConVar("sa_event_include_admins", 0, true, true)
local sa_kickban_reason = CreateClientConVar("sa_kickban_reason", "(Insert Kick/Ban Reason Here)", true, true)
local sa_rcon_text = CreateClientConVar("sa_rcon_text", "sbox_noclip 0", true, true)
local sa_selected_gamemode = CreateClientConVar("sa_selected_gamemode", "sandbox", true, true)
local sa_selected_map = CreateClientConVar("sa_selected_map", "gm_construct", true, true)
local sa_selected_vote = CreateClientConVar("sa_selected_vote", "new", true, true)


local HL2MP_WEAPONS = {
	"weapon_crowbar",
	"weapon_physcannon",
	"weapon_physgun",
	"weapon_stunstick",
	"weapon_pistol",
	"weapon_smg1",
	"weapon_ar2",
	"weapon_357",
	"weapon_shotgun",
	"weapon_crossbow",
	"weapon_rpg",
	"weapon_slam"
}


local PANEL = {}
AccessorFunc(PANEL, "m_bHangOpen", "HangOpen")


// Called when you vgui.Create("saMenu")
function PANEL:Init()
	self.animIn = Derma_Anim("OpenAnim", self, self.OpenAnim)
	self.animOut = Derma_Anim("CloseAnim", self, self.CloseAnim)
	
	self.m_bHangOpen = false
	
	// Tabs
	self:SetSize(270, 400)
	self.tabs = vgui.Create("DPropertySheet", self)
		self.tabs:StretchToParent(0, 0, 0, 0)
		
		// PLAYER MANAGEMENT
		self.pl_mngmnt = vgui.Create("Panel", self.tabs)
			self.pl_mngmnt:StretchToParent(0, 24, 0, 0)
			
			self.pl_list = vgui.Create("DListView", self.pl_mngmnt) 
				local id = self.pl_list:AddColumn("ID")
				id:SetFixedWidth(30)
				local res_slot = self.pl_list:AddColumn("RS")
				res_slot:SetFixedWidth(30)
				self.pl_list:AddColumn("Name")
				self.pl_list:SetMultiSelect(true)
				self.pl_list:StretchToParent(5, 0, 5, 94)
				
			self.ban_time = vgui.Create("DNumSlider", self.pl_mngmnt)
			self.ban_time:SetMinMax(0, 1440)
			self.ban_time:SetDecimals(0)
			self.ban_time:SetConVar("sa_ban_time")
			self.ban_time:SetPos(5, 0)
			self.ban_time:SetWide(225)
			self.ban_time:SetText("Ban Time (Minutes)")
			self.ban_time:MoveBelow(self.pl_list, 4)
			
			self.ban_btn = vgui.Create("DButton", self.pl_mngmnt) 
			self.ban_btn:SetText("Ban")
			self.ban_btn:SetSize(30, 35)
			self.ban_btn:MoveBelow(self.pl_list, 4) 
			self.ban_btn:MoveRightOf(self.ban_time, 5)
			self.ban_btn.DoClick = function()
				local time = sa_ban_time:GetInt()
				local reason = sa_kickban_reason:GetString()
				
				for id, row in pairs(self.pl_list:GetSelected()) do
					RunConsoleCommand("sa_ban", tostring(time), tostring(row:GetColumnText(1)), reason)
					self.pl_list:RemoveLine(id)
				end
			end
			
			self.kickban_reason = vgui.Create("DTextEntry", self.pl_mngmnt)
			self.kickban_reason:SetConVar("sa_kickban_reason")
			self.kickban_reason:SetPos(5, 0)
			self.kickban_reason:SetSize(222, 20)
			self.kickban_reason:MoveBelow(self.ban_time, 4)
			
			self.kick_btn = vgui.Create("DButton", self.pl_mngmnt) 
			self.kick_btn:SetText("Kick")
			self.kick_btn:SetSize(35, 20)
			self.kick_btn:MoveBelow(self.ban_time, 4) 
			self.kick_btn:MoveRightOf(self.kickban_reason, 3)
			self.kick_btn.DoClick = function()
				local reason = sa_kickban_reason:GetString()
				
				for id, row in pairs(self.pl_list:GetSelected()) do
					RunConsoleCommand("sa_kick", tostring(row:GetColumnText(1)), reason)
					self.pl_list:RemoveLine(id)
				end
			end
			
			self.cleanup_btn = vgui.Create("DButton", self.pl_mngmnt) 
			self.cleanup_btn:SetText("Run Cleanup")
			self.cleanup_btn:SetPos(5, 0)
			self.cleanup_btn:SetSize(70, 20)
			self.cleanup_btn:MoveBelow(self.kickban_reason, 4)
			self.cleanup_btn.DoClick = function()
				for _, row in pairs(self.pl_list:GetSelected()) do
					RunConsoleCommand("sa_cleanup", tostring(row:GetColumnText(1)))
				end
			end
			
			self.rules_btn = vgui.Create("DButton", self.pl_mngmnt) 
			self.rules_btn:SetText("Show Rules")
			self.rules_btn:SetSize(65, 20)
			self.rules_btn:MoveBelow(self.kickban_reason, 4)
			self.rules_btn:MoveRightOf(self.cleanup_btn, 3)
			self.rules_btn.DoClick = function()
				for _, row in pairs(self.pl_list:GetSelected()) do
					RunConsoleCommand("sa_rules", tostring(row:GetColumnText(1)))
				end
			end
			
			self.teleto_btn = vgui.Create("DButton", self.pl_mngmnt) 
			self.teleto_btn:SetText("Teleport To ...")
			self.teleto_btn:SetSize(80, 20)
			self.teleto_btn:MoveBelow(self.kickban_reason, 4)
			self.teleto_btn:MoveRightOf(self.rules_btn, 3)
			self.teleto_btn.DoClick = function()
				local teleto_menu = DermaMenu(self.pl_mngmnt) 
				
				teleto_menu:AddOption("(Target)", function()
					local trace = util.QuickTrace(LocalPlayer():GetShootPos(), LocalPlayer():GetAimVector() * 1000000, {LocalPlayer().Entity})
					
					if trace.HitWorld then
						for _, row in pairs(self.pl_list:GetSelected()) do
							RunConsoleCommand("sa_teleport_to", tostring(row:GetColumnText(1)), "0", tostring(trace.HitPos.x), tostring(trace.HitPos.y), tostring(trace.HitPos.z))
						end
					end
				end)
				
				for _, pl2 in pairs(player.GetAll()) do
					teleto_menu:AddOption(pl2:Name(), function()
						for _, row in pairs(self.pl_list:GetSelected()) do
							RunConsoleCommand("sa_teleport_to", tostring(row:GetColumnText(1)), tostring(pl2:UserID()))
						end
					end)
				end
				
				teleto_menu:Open()
			end
			
			self.warn_btn = vgui.Create("DButton", self.pl_mngmnt) 
			self.warn_btn:SetText("Warn")
			self.warn_btn:SetSize(35, 20)
			self.warn_btn:MoveBelow(self.kickban_reason, 4)
			self.warn_btn:MoveRightOf(self.teleto_btn, 3)
			self.warn_btn.DoClick = function()
				for _, row in pairs(self.pl_list:GetSelected()) do
					RunConsoleCommand("sa_warn", tostring(row:GetColumnText(1)))
				end
			end
		
		// EVENT
		self.event = vgui.Create("Panel", self.tabs)
			self.event:StretchToParent(0, 24, 0, 0)
			
			self.wep_list = vgui.Create("DListView", self.event) 
				self.wep_list:AddColumn("Allowed Weapons")
				self.wep_list:SetMultiSelect(true)
				self.wep_list:StretchToParent(5, 0, 5, 30)
				
				for _, weapon in pairs(weapons.GetList()) do
					if !string.find(weapon.ClassName, "_base") then
						self.wep_list:AddLine(weapon.ClassName)
					end
				end
				
				for _, weapon in pairs(HL2MP_WEAPONS) do
					self.wep_list:AddLine(weapon)
				end
				
				self.wep_list:AddLine("")
				
				self.wep_list:SortByColumn(1)
				
			self.include_admins = vgui.Create("DCheckBoxLabel", self.event) 
			self.include_admins:SetText("Include Admins") 
			self.include_admins:SetConVar("sa_event_include_admins")
			self.include_admins:SizeToContents()
			self.include_admins:SetPos(5, 0)
			self.include_admins:SetTextColor(color_black)
			self.include_admins:MoveBelow(self.wep_list, 6) 
			
			self.toggle_event = vgui.Create("DButton", self.event) 
			self.toggle_event:SetText("Toggle Event Mode")
			self.toggle_event:SetSize(100, 20)
			self.toggle_event:MoveBelow(self.wep_list, 3) 
			self.toggle_event:MoveRightOf(self.include_admins, 64)
			self.toggle_event.DoClick = function()
				local weapon_list = ""
				
				for a, weapon in pairs(self.wep_list:GetSelected()) do
					weapon_list = weapon_list..weapon:GetColumnText(1).." "
				end
				
				RunConsoleCommand("sa_event", weapon_list, tostring(sa_event_include_admins:GetInt()))
			end
		
		// VOTING
		self.voting = vgui.Create("Panel", self.tabs)
			self.voting:StretchToParent(0, 24, 0, 0)
			
			self.question_lbl = vgui.Create("DLabel", self.voting)
			self.question_lbl:SetTextColor(color_black)
			self.question_lbl:SetText("Question:")
			self.question_lbl:SizeToContents()
			self.question_lbl:SetPos(5, 0)
			
			self.vote_select = vgui.Create("DMultiChoice", self.voting) 
			self.vote_select:SetPos(5, 0)
			self.vote_select:MoveBelow(self.question_lbl, 5)
			self.vote_select:SetWide(195)
			self.vote_select.OnSelect = function(obj, index, value, data) self:SetupVotingPanel(data) end
			
			self.vote_save = vgui.Create("DButton", self.voting) 
			self.vote_save:SetText("Save")
			self.vote_save:SetSize(40, 20)
			self.vote_save:MoveBelow(self.question_lbl, 5)
			self.vote_save:MoveRightOf(self.vote_select, 5)
			self.vote_save.DoClick = function() self:SaveVotingPanel() end
			
			self.vote_del = vgui.Create("DSysButton", self.voting) 
			self.vote_del:SetType("close")
			self.vote_del:SetSize(15, 20)
			self.vote_del:MoveBelow(self.question_lbl, 5)
			self.vote_del:MoveRightOf(self.vote_save, 5)
			self.vote_del.DoClick = function()
				file.Delete("simple_admin/votes/"..sa_selected_vote:GetString()..".txt")
				self:ResetVoteSelect()
				
				for _, v in pairs(self.vote_options) do
					v:SetText("")
				end
				
				self.vote_end_action:SetText("")
			end
			
			self.options_lbl = vgui.Create("DLabel", self.voting)
			self.options_lbl:SetTextColor(color_black)
			self.options_lbl:SetText("Options:")
			self.options_lbl:SizeToContents()
			self.options_lbl:SetPos(5, 0)
			self.options_lbl:MoveBelow(self.vote_select, 5)
			
			self.vote_options_pnl = vgui.Create("DPanelList", self.voting)
				self.vote_options_pnl:StretchToParent(5, 60, 5, 50)
				self.vote_options_pnl:SetDrawBackground(false)
				self.vote_options_pnl:SetSpacing(5)
				self.vote_options_pnl:EnableHorizontal(false)
				self.vote_options_pnl:EnableVerticalScrollbar(true)
				
				self.vote_options = {}
				
				for a = 1, 20 do
					local option = vgui.Create("DTextEntry", self.vote_options_pnl)
					self.vote_options_pnl:AddItem(option)
					table.insert(self.vote_options, option)
				end
				
			self.vote_end_action_lbl = vgui.Create("DLabel", self.voting)
			self.vote_end_action_lbl:SetTextColor(color_black)
			self.vote_end_action_lbl:SetText("End Action (if first option wins):")
			self.vote_end_action_lbl:SizeToContents()
			self.vote_end_action_lbl:SetPos(5, 0)
			self.vote_end_action_lbl:MoveBelow(self.vote_options_pnl, 5)
			
			self.vote_end_action = vgui.Create("DTextEntry", self.voting)
			self.vote_end_action:SetSize(190, 20)
			self.vote_end_action:SetPos(5, 0)
			self.vote_end_action:MoveBelow(self.vote_end_action_lbl, 5)
			
			self.vote_btn = vgui.Create("DButton", self.voting) 
			self.vote_btn:SetText("Start Vote")
			self.vote_btn:SetSize(65, 20)
			self.vote_btn:MoveBelow(self.vote_end_action_lbl, 5)
			self.vote_btn:MoveRightOf(self.vote_end_action, 5)
			self.vote_btn.DoClick = function() self:StartVote() end
		
		// SERVER MANAGEMENT
		self.svr_mngmng = vgui.Create("Panel", self.tabs)
			self.svr_mngmng:StretchToParent(0, 24, 0, 0)
			
			self.gamemode_lbl = vgui.Create("DLabel", self.svr_mngmng)
			self.gamemode_lbl:SetTextColor(color_black)
			self.gamemode_lbl:SetText("Gamemode:")
			self.gamemode_lbl:SizeToContents()
			self.gamemode_lbl:SetPos(5, 3)
			
			self.gamemode_select = vgui.Create("DMultiChoice", self.svr_mngmng) 
			self.gamemode_select:MoveRightOf(self.gamemode_lbl, 5)
			self.gamemode_select:SetWide(162)
			self.gamemode_select:SetEditable(false)
			self.gamemode_select:SetConVar("sa_selected_gamemode")
			
			for _, gm in pairs(file.FindDir("../gamemodes/*")) do 
				if gm != "base" then
					self.gamemode_select:AddChoice(gm)
					if gm == sa_selected_gamemode:GetString() then
						self.gamemode_select:SetText(gm)
					end
				end
			end
			
			self.map_lbl = vgui.Create("DLabel", self.svr_mngmng)
			self.map_lbl:SetTextColor(color_black)
			self.map_lbl:SetText("Map:")
			self.map_lbl:SizeToContents()
			self.map_lbl:SetPos(5, 0)
			self.map_lbl:MoveBelow(self.gamemode_select, 8)
			
			self.map_select = vgui.Create("DMultiChoice", self.svr_mngmng) 
			self.map_select:SetWide(195)
			self.map_select:MoveBelow(self.gamemode_select, 5)
			self.map_select:MoveRightOf(self.map_lbl, 5)
			self.map_select:SetEditable(true)
			self.map_select:SetConVar("sa_selected_map")
			
			for _, map in pairs(file.Find("../maps/*.bsp")) do 
				if !string.find(map, "background") && !string.find(map, "^test_") && !string.find(map, "^styleguide") && !string.find(map, "^devtest") then
					local map_name = string.gsub(map, ".bsp", "")  
					self.map_select:AddChoice(map_name)
					if map_name == sa_selected_map:GetString() then
						self.map_select:SetText(map_name)
					end
				end
			end
			
			self.mg_go_btn = vgui.Create("DButton", self.svr_mngmng) 
			self.mg_go_btn:SetText("Go!")
			self.mg_go_btn:SetSize(31, 45)
			self.mg_go_btn:MoveRightOf(self.map_select, 5)
			self.mg_go_btn.DoClick = function()
				RunConsoleCommand("sa_rcon", "changegamemode "..sa_selected_map:GetString().." "..sa_selected_gamemode:GetString())
			end
			
			self.rcon_text = vgui.Create("DTextEntry", self.svr_mngmng)
			self.rcon_text:SetConVar("sa_rcon_text")
			self.rcon_text:SetPos(5, 0)
			self.rcon_text:MoveBelow(self.map_select, 5)
			self.rcon_text:SetSize(220, 20)
			
			self.rcon_btn = vgui.Create("DButton", self.svr_mngmng) 
			self.rcon_btn:SetText("RCon")
			self.rcon_btn:SetSize(35, 20)
			self.rcon_btn:MoveRightOf(self.rcon_text, 5)
			self.rcon_btn:MoveBelow(self.map_select, 5)
			self.rcon_btn.DoClick = function()
				RunConsoleCommand("sa_rcon", sa_rcon_text:GetString())
			end
		
		self.tabs:AddSheet("Players", self.pl_mngmnt, "gui/silkicons/group", true, false)
		self.tabs:AddSheet("Event", self.event, "gui/silkicons/star", true, false)
		self.tabs:AddSheet("Voting", self.voting, "gui/silkicons/table_edit", true, false)
		self.tabs:AddSheet("Server", self.svr_mngmng, "gui/silkicons/wrench", true, false)
end


// Opens the panel
function PANEL:Open(bSkipAnim)
	self:SetHangOpen(false)	// Don't stay opened until we are focused on
	
	
	// If the spawn menu or context menu is open, try to close it
	if g_SpawnMenu && g_SpawnMenu:IsVisible() then g_SpawnMenu:Close(true) end
	if g_ContextMenu && g_ContextMenu:IsVisible() then g_ContextMenu:Close(true) end
	
	if self:IsVisible() then return end
	
	CloseDermaMenus()
	
	// Add players (changes all the time)
	self.pl_list:Clear()
	for _, ply in pairs(player.GetAll()) do
		local rs_txt = ""
		local rs_used = ply:GetNWInt("reserved_slot_used")
		if rs_used && rs_used > 0 then
			rs_txt = rs_used.."/"..SA_RESERVED_SLOTS
		end
		self.pl_list:AddLine(ply:UserID(), rs_txt, ply:Nick())
	end
	
	// Setup voting
	self:ResetVoteSelect()
	
	// Disable certain things
	if !GAMEMODE.IsSandboxDerived then
		self.cleanup_btn:SetDisabled(true)
		self.toggle_event:SetDisabled(true)
	end
	if !LocalPlayer():IsSuperAdmin() then
		self.rcon_btn:SetDisabled(true)
	end
	
	self:MakePopup()
	self:SetVisible(true)
	self:SetKeyboardInputEnabled(false)
	self:SetMouseInputEnabled(true)
	
	RestoreCursorPosition()
	
	self.animOut:Stop()
	self.animIn:Stop()
	
	self:InvalidateLayout(true)
	
	if bSkipAnim then
		self:SetAlpha(255)
		self:SetVisible(true)
	else
		self.animIn:Start(0.1, {TargetX = self.x})
	end
end


// Closes the panel
function PANEL:Close(bSkipAnim)
	if self:GetHangOpen() then 
		self:SetHangOpen(false)
		return
	end
	
	RememberCursorPosition()
	
	CloseDermaMenus()

	self:SetKeyboardInputEnabled(false)
	self:SetMouseInputEnabled(false)
	
	self.animIn:Stop()
	
	if bSkipAnim then
		self:SetAlpha(255)
		self:SetVisible(false)
	else
		self.animOut:Start(0.1, {StartX = self.x})
	end
end


//  Called every frame
function PANEL:Think()
	if (g_SpawnMenu && g_SpawnMenu:IsVisible()) || (g_ContextMenu && g_ContextMenu:IsVisible()) then 	
		self:Close(true)	// Because spawn menu and context menu don't care
	end
	
	self.animIn:Run()
	self.animOut:Run()
end


// Called on invalidate layout
function PANEL:PerformLayout()
	self:SetPos(ScrW() - self:GetWide() - 25, ScrH() - self:GetTall() - 25) 
	
	self.animIn:Run() 
	self.animOut:Run() 
end


// Called when we gain focus
function PANEL:StartKeyFocus(panel)
	self:SetKeyboardInputEnabled(true)
	self:SetHangOpen(true)
end


// Called when we loose focus
function PANEL:EndKeyFocus(panel)
	self:SetKeyboardInputEnabled(false)
end


// Does the opening animation
function PANEL:OpenAnim(anim, delta, data)
	if anim.Started then
		// WTF, Garry?
	end
	
	if anim.Finished then
		self.x = data.TargetX
		return
	end
	
	local Distance = ScrW() - data.TargetX
	
	self.x = data.TargetX + Distance - Distance * (delta ^ 0.1)
end


// Does the animation for closing
function PANEL:CloseAnim(anim, delta, data)
	if anim.Finished then
		self:SetVisible(false)
		return 
	end
	
	local Distance = ScrW() - data.StartX
	
	self.x = data.StartX + Distance * (delta ^ 2)
end


// Resets stuff
function PANEL:ResetVoteSelect()
	self.vote_select:Clear()
	self.vote_select:AddChoice("(New)", "new") 
	
 	for _, file_name in pairs(file.Find("simple_admin/votes/*.txt")) do
		local file_info = util.KeyValuesToTable(file.Read("simple_admin/votes/"..file_name))
 		self.vote_select:AddChoice(file_info.question, string.Replace(file_name,".txt",""))
 		if sa_selected_vote:GetString()..".txt" == file_name && file_info.question then
 			self.vote_select:SetText(file_info.question)
			self:SetupVotingPanel(sa_selected_vote:GetString())
 		end
 	end
end


// Saves the vote
function PANEL:SaveVotingPanel()
	if !self.vote_select.TextEntry:GetValue() then return end
	
	local vote_info = {}
	vote_info.question = self.vote_select.TextEntry:GetValue()
	vote_info.end_action = self.vote_end_action:GetValue()
	vote_info.options = {}
	
	for _, v in pairs(self.vote_options) do
		if v:GetValue() then
			table.insert(vote_info.options, v:GetValue())
		end
	end
	
	if file.Exists("simple_admin/votes/"..sa_selected_vote:GetString()..".txt") then
		file.Delete("simple_admin/votes/"..sa_selected_vote:GetString()..".txt")
	end

	file.Write("simple_admin/votes/"..sa_selected_vote:GetString()..".txt", util.TableToKeyValues(vote_info))
	
	self:ResetVoteSelect()
end


// Sets up the voting panel
function PANEL:SetupVotingPanel(vote_id)
	if vote_id == "new" then
		local new_vote_id = string.Replace(CurTime(),".","")
		self.vote_select:AddChoice("Question?", new_vote_id)
		self.vote_select:SetText("Question?")
		
		RunConsoleCommand("sa_selected_vote", new_vote_id)
		
		for k, v in pairs(self.vote_options) do
			v:SetText("")
		end
		
		self.vote_end_action:SetText("")
	elseif file.Read("simple_admin/votes/"..vote_id..".txt") then
		RunConsoleCommand("sa_selected_vote", vote_id)
		
		local file_info = util.KeyValuesToTable(file.Read("simple_admin/votes/"..vote_id..".txt"))
		
		for k, v in pairs(self.vote_options) do
			if file_info.options && file_info.options[tostring(k)] then
				v:SetText(file_info.options[ tostring(k)])
			else
				v:SetText("")
			end
		end
		
		if file_info.end_action then
			self.vote_end_action:SetText(file_info.end_action)
		else
			self.vote_end_action:SetText("")
		end
	end
end


// Starts the vote
function PANEL:StartVote()
	self:SaveVotingPanel()
	
	local con_text = "sa_create_vote 1 \""..self.vote_select.TextEntry:GetValue().."\" "
	
	for k, v in pairs(self.vote_options) do
		if v:GetValue() && v:GetValue() != "" then
			con_text = con_text.."\""..v:GetValue().."\" "
		end
	end
	
	RunConsoleCommand("sa_set_vote_end_action", self.vote_end_action:GetValue())
	LocalPlayer():ConCommand(con_text.."\n")
end


// Register our new panel
vgui.Register("saMenu", PANEL, "EditablePanel")


// Called when text entry needs keyboard focus 
local function saMenuKeyboardFocusOn(panel) 
	if !sa_menu then return end 
	sa_menu:StartKeyFocus(panel) 
end 
hook.Add("OnTextEntryGetFocus", "saMenuKeyboardFocusOn", saMenuKeyboardFocusOn) 


// Called when text entry stops needing keyboard focus 
local function saMenuKeyboardFocusOff(panel) 
	if !sa_menu then return end 
	sa_menu:EndKeyFocus(panel)
end 
hook.Add("OnTextEntryLoseFocus", "saMenuKeyboardFocusOff", saMenuKeyboardFocusOff) 



// Create the simple admin menu if we need to
local function saCreateMenu()
	if sa_menu then
		sa_menu:Remove()
		sa_menu = nil
	end
	
	sa_menu = vgui.Create("saMenu")
	sa_menu:SetVisible(false)
end
hook.Add("OnGamemodeLoaded", "saCreateMenu", saCreateMenu)


// Opens our menu
local function saToggleMenu(pl, command, arguments)
	if !LocalPlayer():IsAdmin() || !sa_menu then return end 
	
	if command == "+sa_menu" then
		sa_menu:Open()
	else
		sa_menu:Close()
	end
end
concommand.Add("+sa_menu", saToggleMenu)
concommand.Add("-sa_menu", saToggleMenu)
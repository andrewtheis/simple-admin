// Do we have a local meta table?
local meta = FindMetaTable("Player")
if !meta then return end


if SERVER then
	// Shows player a fancy message
	function meta:FancyMsg(msgtype, msg, ent)
		if ent && self.last_msg_ent && self.last_msg_ent == ent then return end
		self.last_msg_ent = ent
		self:SendLua("GAMEMODE:AddNotify(\""..msg.."\", "..msgtype..", 5)")
		
		if msgtype == "NOTIFY_ERROR" then
			self:SendLua("surface.PlaySound('buttons/button10.wav')")
		end
	end
	
	
	// Returns if player is VIP or not
	function meta:IsVIP()
		if !VIP_IDS then return false end
		
		for _, sid in pairs(VIP_IDS) do
			if tostring(self:SteamID()) == tostring(sid) then
				return true
			end
		end
		
		return false
	end
end
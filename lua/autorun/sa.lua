// If we are in single player, don't load
if SinglePlayer() then return end

// Decide what to initialize
if SERVER then
	include("sa_server.lua")
elseif CLIENT then
	include("sa_client.lua")
end 
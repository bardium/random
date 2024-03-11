if not game:IsLoaded() then
	game.Loaded:Wait()
end

if game.PlaceId ~= 16462849084 then
	return
end

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local localPlayer = Players.LocalPlayer
local itemPickups = Workspace:WaitForChild("Temp"):WaitForChild("ItemPickups")

repeat task.wait() until localPlayer.Character ~= nil

local rootPart = localPlayer.Character:WaitForChild("HumanoidRootPart")

while task.wait() do
	for _, instance in itemPickups:GetChildren() do
		rootPart.CFrame = instance:GetPivot()
		task.wait()
	end
	if #itemPickups:GetChildren() < 0 then
		local queueonteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
		if queueonteleport then
			queueonteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/bardium/random/main/godzillakongobby.lua'))()")
		end
		local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
		if httprequest then
			local servers = {}
			local req = httprequest({Url = string.format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100", game.PlaceId)})
			local body = game:GetService("HttpService"):JSONDecode(req.Body)
			if body and body.data then
				for i, v in next, body.data do
					if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= game.JobId then
						table.insert(servers, 1, v.id)
					end 
				end
			end
			if #servers > 0 then
				print("tried serverhopping")
				TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], localPlayer)
			else
				if body and body.data then
					for i, v in next, body.data do
						if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= game.JobId then
							table.insert(servers, 1, v.id)
						end 
					end
				end
				if #servers > 0 then
					print("tried serverhopping")
					TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], localPlayer)
				end
			end
		end
	end
end

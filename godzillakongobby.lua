-- Enable Auto Execute for Auto Rejoin

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local placeId, jobId = 16462849084, game.JobId

if game.PlaceId ~= placeId then
	return
end

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer
local itemPickups = Workspace:WaitForChild("Temp"):WaitForChild("ItemPickups")
local cube = Workspace:WaitForChild("CrystalLobby")
	:WaitForChild("OpeningCutscene")
	:WaitForChild("ArmCamera")
	:WaitForChild("Cube")

local httprequest = (syn and syn.request)
	or (http and http.request)
	or http_request
	or (fluxus and fluxus.request)
	or request
local queueonteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)

local teleporting = false

repeat
	task.wait()
until localPlayer.Character ~= nil

local rootPart = localPlayer.Character:WaitForChild("HumanoidRootPart")

rootPart.CFrame = cube.CFrame

local eeeeattempts = 0
repeat
	task.wait()
until Workspace.CurrentCamera.CameraType == Enum.CameraType.Scriptable or eeeeattempts > 50
repeat
	task.wait()
until Workspace.CurrentCamera.CameraType ~= Enum.CameraType.Scriptable or eeeeattempts > 100

task.wait(1)

local currencyLabel = localPlayer.PlayerGui.CurrencyUI.Container.CurrencyLabel

local oldAmount = 0
local timesFailed = 0

local function rejoin()
	if queueonteleport then
		--queueonteleport("loadstring(game:HttpGet('https://raw.githubusercontent.com/bardium/random/main/godzillakongobby.lua'))()")
	end
	if httprequest and not teleporting then
		local servers = {}
		local req = httprequest({
			Url = string.format(
				"https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true",
				placeId
			),
		})
		local body = HttpService:JSONDecode(req.Body)
		if body and body.data then
			for i, v in next, body.data do
				if
					type(v) == "table"
					and tonumber(v.playing)
					and tonumber(v.maxPlayers)
					and v.playing < v.maxPlayers
					and v.id ~= jobId
				then
					table.insert(servers, 1, v.id)
				end
			end
		end
		if #servers > 0 then
			teleporting = true
			TeleportService:TeleportToPlaceInstance(placeId, servers[math.random(1, #servers)], localPlayer)
		end
	end
end

local excludedCheckpoints = {}

local function tryCheckpoint()
	local checkpointParts = {}
	for _, x in Workspace:GetDescendants() do
		if x.Name == "SC_Checkpoint" and x.Parent:IsA("BasePart") and not table.find(excludedCheckpoints, x.Parent) then
			table.insert(checkpointParts, x.Parent)
		end
	end

	local closetCheckpoint = nil
	for _, x in checkpointParts do
		if closetCheckpoint then
			local distanceFromX = (rootPart.Position - x.Position).Magnitude
			local distanceFromClosestCheckpoint = (rootPart.Position - closetCheckpoint.Position).Magnitude
			if distanceFromX < distanceFromClosestCheckpoint then
				closetCheckpoint = x
			end
		else
			closetCheckpoint = x
		end
	end
	if closetCheckpoint then
		timesFailed += 1
		for i = 0, 3 do
			rootPart.CFrame = CFrame.new(closetCheckpoint.Position) * CFrame.new(0, 4, 0)
			task.wait(1)
		end
		table.insert(excludedCheckpoints, closetCheckpoint)
	else
		warn("Checkpoint not found!", #checkpointParts)
	end
	oldAmount -= 1
end

while task.wait() do
	local pickups = {}
	for _, instance in itemPickups:GetChildren() do
		if instance:IsA("PVInstance") and string.find(instance.Name, "IP_") then
			table.insert(pickups, instance)
		end
	end
	table.sort(pickups, function(a, b)
		local distanceFromCharacterA = (rootPart.Position - a:GetPivot().Position).Magnitude
		local distanceFromCharacterB = (rootPart.Position - b:GetPivot().Position).Magnitude
		return distanceFromCharacterA < distanceFromCharacterB
	end)
	if #pickups > 10 then
		for _, pickup in pickups do
			local attempts = 0
			repeat
				task.wait(0.1)
				attempts += 1
				rootPart.CFrame = pickup:GetPivot()
			until tonumber(currencyLabel.Text) > oldAmount or attempts > 10
			if attempts > 10 then
				rejoin()
			end
			oldAmount = tonumber(currencyLabel.Text)
		end
	else
		rejoin()
	end
	if attempts > 10 then
		rejoin()
	end
end

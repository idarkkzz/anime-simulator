local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RequestTeleport = Remotes:WaitForChild("RequestTeleport")
local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))

local function getPlayerSpawnCFrame(islandId)
	local islandsFolder = Workspace:FindFirstChild("Islands")
	if not islandsFolder then return nil end
	local islandFolder = islandsFolder:FindFirstChild(islandId)
	if not islandFolder then return nil end
	local spawns = islandFolder:FindFirstChild("PlayerSpawns")
	if not spawns then return nil end
	for _, part in ipairs(spawns:GetChildren()) do
		if part:IsA("BasePart") then
			return part.CFrame + Vector3.new(0, 3, 0)
		end
	end
	return nil
end

local function teleportToIsland(player, islandIndex)
	local island = Config:GetIslandByIndex(islandIndex)
	if not island then return false, "Ilha inválida" end
	local cframe = getPlayerSpawnCFrame(island.Id)
	if not cframe then return false, "Spawn da ilha não encontrado" end

	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return false, "Sem personagem" end

	root.CFrame = cframe

	local ls = player:FindFirstChild("leaderstats")
	if ls then
		local idx = ls:FindFirstChild("IslandIndex")
		local name = ls:FindFirstChild("IslandName")
		local islandKills = ls:FindFirstChild("IslandKills")
		if idx then idx.Value = islandIndex end
		if name then name.Value = island.Name end
		if islandKills then islandKills.Value = 0 end
	end

	return true
end

RequestTeleport.OnServerEvent:Connect(function(player)
	local ls = player:FindFirstChild("leaderstats")
	if not ls then return end
	local idx = ls:FindFirstChild("IslandIndex") and ls.IslandIndex.Value or 1
	local islandKills = ls:FindFirstChild("IslandKills") and ls.IslandKills.Value or 0

	local currentIsland = Config:GetIslandByIndex(idx)
	local nextIsland = Config:GetIslandByIndex(idx + 1)

	if not nextIsland then
		return
	end

	local required = currentIsland.RequiredKillsForNext or 0
	if islandKills >= required then
		teleportToIsland(player, idx + 1)
	else
		warn(("Jogador %s não cumpre requisito: %d/%d"):format(player.Name, islandKills, required))
	end
end)

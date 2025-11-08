local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GetProgress = Remotes:WaitForChild("GetProgress")
local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))

GetProgress.OnServerInvoke = function(player)
	local ls = player:FindFirstChild("leaderstats")
	if not ls then return nil end
	local idx = ls:FindFirstChild("IslandIndex") and ls.IslandIndex.Value or 1
	local island = Config:GetIslandByIndex(idx)
	local nextIsland = Config:GetIslandByIndex(idx + 1)

	local islandKills = ls:FindFirstChild("IslandKills") and ls.IslandKills.Value or 0
	local required = nextIsland and island.RequiredKillsForNext or nil

	return {
		currentIslandIndex = idx,
		currentIslandId = island and island.Id or "",
		currentIslandName = island and island.Name or "",
		currentIslandKills = islandKills,
		requiredKillsForNext = required,
		nextIslandId = nextIsland and nextIsland.Id or nil,
		nextIslandName = nextIsland and nextIsland.Name or nil,
		isLastIsland = (nextIsland == nil),
	}
end

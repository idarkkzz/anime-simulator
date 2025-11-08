local Players = game:GetService("Players")
local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Config"))

Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 0
	coins.Parent = leaderstats

	local kills = Instance.new("IntValue")
	kills.Name = "Kills"
	kills.Value = 0
	kills.Parent = leaderstats

	local islandIndex = Instance.new("IntValue")
	islandIndex.Name = "IslandIndex"
	islandIndex.Value = 1
	islandIndex.Parent = leaderstats

	local islandName = Instance.new("StringValue")
	islandName.Name = "IslandName"
	islandName.Value = Config.Islands[1].Name
	islandName.Parent = leaderstats

	local islandKills = Instance.new("IntValue")
	islandKills.Name = "IslandKills"
	islandKills.Value = 0
	islandKills.Parent = leaderstats
end)

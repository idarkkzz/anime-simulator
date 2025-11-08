-- Configuração de ilhas, NPCs e regras de progressão

local Config = {}

Config.Islands = {
	{
		Id = "start",
		Name = "Start Island",
		RequiredKillsForNext = 0,
		NPCs = {
			{ Type = "Bandit", Count = 6, RespawnTime = 6 },
		},
	},
	{
		Id = "desert",
		Name = "Desert",
		RequiredKillsForNext = 25,
		NPCs = {
			{ Type = "SandThug", Count = 8, RespawnTime = 7 },
		},
	},
	{
		Id = "sky",
		Name = "Sky Island",
		RequiredKillsForNext = 60,
		NPCs = {
			{ Type = "SkyNinja", Count = 10, RespawnTime = 8 },
		},
	},
}

Config.NPCTypes = {
	Bandit   = { MaxHealth = 50,  Damage = 5,  RewardCoins = 5 },
	SandThug = { MaxHealth = 120, Damage = 9,  RewardCoins = 12 },
	SkyNinja = { MaxHealth = 250, Damage = 15, RewardCoins = 25 },
}

Config.MaxAttackRange = 14
Config.BasePlayerDamage = 10

function Config:GetIslandById(id)
	for idx, island in ipairs(self.Islands) do
		if island.Id == id then
			return island, idx
		end
	end
	return nil, nil
end

function Config:GetIslandByIndex(index)
	return self.Islands[index]
end

function Config:IsLastIsland(index)
	return index >= #self.Islands
end

return Config

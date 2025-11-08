local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))
local NPCAI = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("NPCAI"))

local function getNPCFolder()
	local f = Workspace:FindFirstChild("NPCs")
	if not f then
		f = Instance.new("Folder")
		f.Name = "NPCs"
		f.Parent = Workspace
	end
	return f
end

local function getTemplate(typeName)
	local folder = ReplicatedStorage:FindFirstChild("NPCs")
	if not folder then return nil end
	return folder:FindFirstChild(typeName)
end

local function createHealthBillboard(model, humanoid)
	local bb = Instance.new("BillboardGui")
	bb.Name = "HealthUI"
	bb.Size = UDim2.new(0, 100, 0, 18)
	bb.StudsOffset = Vector3.new(0, 4, 0)
	bb.AlwaysOnTop = true
	bb.Parent = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")

	local tl = Instance.new("TextLabel")
	tl.Size = UDim2.new(1, 0, 1, 0)
	tl.BackgroundTransparency = 1
	tl.TextColor3 = Color3.fromRGB(255, 255, 255)
	tl.TextStrokeTransparency = 0.5
	tl.Font = Enum.Font.GothamBold
	tl.TextScaled = true
	tl.Parent = bb

	local function update()
		if humanoid and humanoid.MaxHealth > 0 then
			tl.Text = string.format("%d/%d", math.max(0, math.floor(humanoid.Health + 0.5)), math.floor(humanoid.MaxHealth + 0.5))
		end
	end
	update()
	humanoid.HealthChanged:Connect(update)
end

local function tagCreator(humanoid, player)
	local tag = humanoid:FindFirstChild("creator")
	if not tag then
		tag = Instance.new("ObjectValue")
		tag.Name = "creator"
		tag.Parent = humanoid
	end
	tag.Value = player
end

local function connectRewards(npcModel, islandIndex, npcTypeStats)
	local humanoid = npcModel:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	humanoid.Died:Connect(function()
		local creator = humanoid:FindFirstChild("creator")
		local player = creator and creator.Value
		if player and player.Parent == game.Players then
			local ls = player:FindFirstChild("leaderstats")
			if ls then
				local coins = ls:FindFirstChild("Coins")
				local kills = ls:FindFirstChild("Kills")
				local islandIndexValue = ls:FindFirstChild("IslandIndex")
				local islandKills = ls:FindFirstChild("IslandKills")
				if coins then coins.Value += (npcTypeStats.RewardCoins or 1) end
				if kills then kills.Value += 1 end
				if islandKills and islandIndexValue and islandIndexValue.Value == islandIndex then
					islandKills.Value += 1
				end
			end
		end
	end)
end

local function setupNPC(npcModel, islandIndex, npcTypeStats)
	local humanoid = npcModel:FindFirstChildOfClass("Humanoid")
	local root = npcModel:FindFirstChild("HumanoidRootPart")
	if not (humanoid and root) then
		warn("NPC inválido:", npcModel)
		return
	end

	npcModel:SetAttribute("IsNPC", true)
	npcModel:SetAttribute("IslandIndex", islandIndex)
	npcModel:SetAttribute("NPCType", "unknown")

	humanoid.MaxHealth = npcTypeStats.MaxHealth or 100
	humanoid.Health = humanoid.MaxHealth

	createHealthBillboard(npcModel, humanoid)

	NPCAI.Bind(npcModel, {
		AggroRange = 40,
		WalkRadius = 28,
		Damage = npcTypeStats.Damage or 5,
	})

	connectRewards(npcModel, islandIndex, npcTypeStats)
end

local function spawnOne(configIsland, islandIndex, npcEntry, spawnPoint)
	local typeName = npcEntry.Type
	local template = getTemplate(typeName)
	if not template then
		warn("Template NPC não encontrado:", typeName)
		return nil
	end

	local clone = template:Clone()
	clone.Name = typeName
	clone.Parent = getNPCFolder()
	local hrp = clone:FindFirstChild("HumanoidRootPart")
	if hrp and spawnPoint then
		hrP.CFrame = spawnPoint.CFrame + Vector3.new(0, 3, 0)
	end

	local stats = Config.NPCTypes[typeName] or {}
	clone:SetAttribute("NPCType", typeName)
	setupNPC(clone, islandIndex, stats)
	return clone
end

local function spawnIsland(configIsland, islandIndex, islandFolder)
	local spawnsFolder = islandFolder:FindFirstChild("NPCSpawnPoints")
	if not spawnsFolder then
		warn("Ilha sem NPCSpawnPoints:", islandFolder.Name)
		return
	end
	local spawnPoints = {}
	for _, p in ipairs(spawnsFolder:GetChildren()) do
		if p:IsA("BasePart") then
			table.insert(spawnPoints, p)
		end
	end
	if #spawnPoints == 0 then
		warn("Nenhum spawn point na ilha:", islandFolder.Name)
		return
	end

	for _, entry in ipairs(configIsland.NPCs or {}) do
		local count = entry.Count or 5
		local respawn = entry.RespawnTime or 7
		local active = {}

		local function doRespawn(index)
			task.delay(respawn, function()
				local point = spawnPoints[((index - 1) % #spawnPoints) + 1]
				local npc = spawnOne(configIsland, islandIndex, entry, point)
				if npc then
					active[index] = npc
					local hum = npc:FindFirstChildOfClass("Humanoid")
					if hum then
						hum.Died:Connect(function()
							active[index] = nil
							doRespawn(index)
						end)
					end
				else
					doRespawn(index)
				end
			end)
		end

		for i = 1, count do
			doRespawn(i)
		end
	end
end

Task.spawn(function()
	local islandsFolder = Workspace:WaitForChild("Islands", 10)
	if not islandsFolder then
		warn("Workspace.Islands não encontrado. Crie as pastas das ilhas.")
		return
	end

	for idx, island in ipairs(Config.Islands) do
		local folder = islandsFolder:FindFirstChild(island.Id)
		if folder then
			spawnIsland(island, idx, folder)
		else
			warn("Pasta da ilha não encontrada no Workspace.Islands:", island.Id)
		end
	end
end)

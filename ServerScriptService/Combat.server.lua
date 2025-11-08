local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local DamageNPC = Remotes:WaitForChild("DamageNPC")

local Config = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Config"))

local lastAttack = {}
local ATTACK_COOLDOWN = 0.35

local function isValidNPC(model)
	if not model or not model:IsA("Model") then return false end
	local hum = model:FindFirstChildOfClass("Humanoid")
	local hrp = model:FindFirstChild("HumanoidRootPart")
	if not (hum and hrp) then return false end
	if hum.Health <= 0 then return false end
	if not model:GetAttribute("IsNPC") then return false end
	return true
end

local function withinRange(player, targetRoot, maxRange)
	local char = player.Character
	if not char then return false end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return false end
	local dist = (root.Position - targetRoot.Position).Magnitude
	return dist <= (maxRange or Config.MaxAttackRange)
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

DamageNPC.OnServerEvent:Connect(function(player, npcModel, clientProposedDamage)
	if typeof(npcModel) ~= "Instance" then return end
	if typeof(clientProposedDamage) ~= "number" then return end

	local now = os.clock()
	if (lastAttack[player] or 0) + ATTACK_COOLDOWN > now then
		return
	end

	if not isValidNPC(npcModel) then return end

	local hum = npcModel:FindFirstChildOfClass("Humanoid")
	local hrp = npcModel:FindFirstChild("HumanoidRootPart")
	if not (hum and hrp) then return end

	if not withinRange(player, hrp, Config.MaxAttackRange) then
		return
	end

	local damage = math.clamp(math.floor(clientProposedDamage), 1, 250)

	tagCreator(hum, player)
	hum:TakeDamage(damage)

	lastAttack[player] = now
end)

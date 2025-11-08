local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local DamageNPC = Remotes:WaitForChild("DamageNPC")

local BASE_DAMAGE = 10

local function nearestNPC(maxRange)
	local npcsFolder = Workspace:FindFirstChild("NPCs")
	if not npcsFolder then return nil, math.huge end

	local myChar = player.Character
	local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
	if not myRoot then return nil, math.huge end

	local best, bestDist = nil, maxRange or 9999
	for _, model in ipairs(npcsFolder:GetChildren()) do
		if model:IsA("Model") and model:GetAttribute("IsNPC") then
			local hum = model:FindFirstChildOfClass("Humanoid")
			local root = model:FindFirstChild("HumanoidRootPart")
			if hum and root and hum.Health > 0 then
				local d = (myRoot.Position - root.Position).Magnitude
				if d < bestDist then
					bestDist = d
					best = model
				end
			end
		end
	end
	return best, bestDist
end

local function attack()
	local target, dist = nearestNPC(18)
	if not target then return end
	DamageNPC:FireServer(target, BASE_DAMAGE)
end

UserInputService.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		attack()
	elseif input.KeyCode == Enum.KeyCode.F then
		attack()
	end
end)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local NPCAI = {}

local function getHumanoidAndRoot(model)
	local hum = model:FindFirstChildOfClass("Humanoid")
	local root = model:FindFirstChild("HumanoidRootPart")
	return hum, root
end

local function distance(a, b)
	return (a - b).Magnitude
end

local function nearestPlayer(root, maxDist)
	local nearest, minD = nil, maxDist
	for _, plr in ipairs(Players:GetPlayers()) do
		local char = plr.Character
		if char then
			local proot = char:FindFirstChild("HumanoidRootPart")
			local phum = char:FindFirstChildOfClass("Humanoid")
			if proot and phum and phum.Health > 0 then
				local d = distance(root.Position, proot.Position)
				if d <= minD then
					minD = d
					nearest = proot
				end
			end
		end
	end
	return nearest
end

function NPCAI.Bind(npcModel, props)
	props = props or {}
	local AggroRange = props.AggroRange or 35
	local WalkRadius = props.WalkRadius or 25

	local humanoid, root = getHumanoidAndRoot(npcModel)
	if not (humanoid and root) then
		warn("NPCAI: npcModel sem Humanoid/Root", npcModel)
		return
	end

	local spawnPos = root.Position
	local isDead = false

	humanoid.Died:Connect(function()
		isDead = true
	end)

	task.spawn(function()
		while not isDead and npcModel.Parent do
			local targetRoot = nearestPlayer(root, AggroRange)
			if targetRoot then
				humanoid:MoveTo(targetRoot.Position)
			else
				local randomOffset = Vector3.new(
					math.random(-WalkRadius, WalkRadius),
					0,
					math.random(-WalkRadius, WalkRadius)
				)
				local target = spawnPos + randomOffset
				humanoid:MoveTo(target)
			end
			humanoid.MoveToFinished:Wait(2)
			task.wait(math.random(1, 2))
		end
	end)
end

return NPCAI

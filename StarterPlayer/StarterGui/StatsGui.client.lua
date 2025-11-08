local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local GetProgress = Remotes:WaitForChild("GetProgress")
local RequestTeleport = Remotes:WaitForChild("RequestTeleport")

local screen = Instance.new("ScreenGui")
screen.Name = "StatsGui"
screen.ResetOnSpawn = false
screen.IgnoreGuiInset = true
screen.Parent = player:WaitForChild("PlayerGui")

local function newLabel(parent, text, pos)
	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 0.35
	lbl.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.TextStrokeTransparency = 0.5
	lbl.Font = Enum.Font.GothamBold
	lbl.TextScaled = true
	lbl.Size = UDim2.new(0, 300, 0, 36)
	lbl.Position = pos
	lbl.Text = text
	lbl.Parent = parent
	return lbl
end

local coinsLbl = newLabel(screen, "Coins: 0", UDim2.new(0, 12, 0, 12))
local killsLbl = newLabel(screen, "Kills: 0", UDim2.new(0, 12, 0, 54))
local islandLbl = newLabel(screen, "Ilha: -", UDim2.new(0, 12, 0, 96))
local progressLbl = newLabel(screen, "Progresso: -", UDim2.new(0, 12, 0, 138))

local travelBtn = Instance.new("TextButton")
travelBtn.Text = "Viajar p/ próxima ilha"
travelBtn.Font = Enum.Font.GothamBold
travelBtn.TextScaled = true
travelBtn.TextColor3 = Color3.fromRGB(255,255,255)
travelBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
travelBtn.Size = UDim2.new(0, 300, 0, 40)
travelBtn.Position = UDim2.new(0, 12, 0, 184)
travelBtn.Visible = false
travelBtn.Parent = screen

travelBtn.MouseButton1Click:Connect(function()
	RequestTeleport:FireServer()
end)

local function bindLeaderstats()
	local ls = player:WaitForChild("leaderstats", 10)
	if not ls then return end

	local function update()
		local coins = ls:FindFirstChild("Coins") and ls.Coins.Value or 0
		local kills = ls:FindFirstChild("Kills") and ls.Kills.Value or 0
		local islandName = ls:FindFirstChild("IslandName") and ls.IslandName.Value or "-"
		coinsLbl.Text = ("Coins: %d"):format(coins)
		killsLbl.Text = ("Kills: %d"):format(kills)
		islandLbl.Text = ("Ilha: %s"):format(islandName)
	end
	update()

	for _, child in ipairs(ls:GetChildren()) do
		if child:IsA("ValueBase") then
			child:GetPropertyChangedSignal("Value"):Connect(update)
		end
	end
	ls.ChildAdded:Connect(function(c)
		if c:IsA("ValueBase") then
			c:GetPropertyChangedSignal("Value"):Connect(update)
		end
	end)
end

bindLeaderstats()

local function refreshProgressUI()
	local ok, data = pcall(function()
		return GetProgress:InvokeServer()
	end)
	if not ok or not data then return end

	if data.isLastIsland then
		progressLbl.Text = "Última ilha!"
		travelBtn.Visible = false
	else
		local req = data.requiredKillsForNext or 0
		local cur = data.currentIslandKills or 0
		progressLbl.Text = ("Progresso: %d/%d kills para %s"):format(cur, req, data.nextIslandName or "?")
		travelBtn.Visible = cur >= req
	end
end

Task.spawn(function()
	while true do
		refreshProgressUI()
		Task.wait(1.0)
	end
end)

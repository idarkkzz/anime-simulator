local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function ensureFolder(parent, name)
	local f = parent:FindFirstChild(name)
	if not f then
		f = Instance.new("Folder")
		f.Name = name
		f.Parent = parent
	end
	return f
end

local remotes = ensureFolder(ReplicatedStorage, "Remotes")

local function ensureRemoteEvent(name)
	local ev = remotes:FindFirstChild(name)
	if not ev then
		ev = Instance.new("RemoteEvent")
		ev.Name = name
		ev.Parent = remotes
	end
	return ev
end

local function ensureRemoteFunction(name)
	local fn = remotes:FindFirstChild(name)
	if not fn then
		fn = Instance.new("RemoteFunction")
		fn.Name = name
		fn.Parent = remotes
	end
	return fn
end

ensureRemoteEvent("DamageNPC")
ensureRemoteEvent("RequestTeleport")
ensureRemoteFunction("GetProgress")

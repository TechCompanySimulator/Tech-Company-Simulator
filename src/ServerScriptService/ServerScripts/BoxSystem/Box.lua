local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Maid = loadModule("Maid")

local Box = {}
Box.__index = Box

function Box.new(owner, boxType, cf, id)
	local self = setmetatable({}, Box)

	self.maid = Maid.new()
	local boxAsset = ReplicatedStorage.Assets.Boxes:FindFirstChild(boxType)
	if not boxAsset then
		error("Box type not found: " .. boxType)
		return
	end

	self.model = boxAsset:Clone()
	self.model:PivotTo(cf)
	self.model:SetAttribute("Id", tostring(id))
	self.model:SetAttribute("OwnerId", owner.UserId)
	self.model.Parent = workspace

	self.owner = owner
	self.id = id

	return self
end

function Box:Pickup(player)
	if player ~= self.owner then warn("This player does not own the box") return false end

	if self.model:GetAttribute("Sold") then return false end

	local char = player.Character
	if not char or (not char:FindFirstChild("UpperTorso") and not char:FindFirstChild("Torso")) then return false end

	local torso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
	for _, part in self.model:GetDescendants() do
		if not part:IsA("BasePart") then continue end

		part.Anchored = false
		part.CanCollide = false
	end

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = torso
	weld.Part1 = self.model.PrimaryPart
	self.model:PivotTo(torso.CFrame * CFrame.new(0, 0, -2))

	weld.Parent = self.model.PrimaryPart

	return true
end

function Box:Drop(player)
	if player ~= self.owner then warn("This player does not own the box") return false end

	local primPart = self.model.PrimaryPart
	if not primPart then return false end

	local weld = primPart:FindFirstChildOfClass("WeldConstraint")
	if not weld then warn("Weld not found in box") return false end

	for _, part in self.model:GetDescendants() do
		if not part:IsA("BasePart") then continue end

		part.CanCollide = true
	end

	weld:Destroy()

	return true
end

function Box:Destroy()
	self.maid:doCleaning()
end

return Box
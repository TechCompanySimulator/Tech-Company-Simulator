local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

if RunService:IsServer() then return {} end

local Camera = workspace.CurrentCamera

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local camTypeChanged = getDataStream("CamTypeChanged", "BindableEvent")

local player = Players.LocalPlayer

local Cam = {
	currentType = "Default";
}

-- Compile all of the camera modes into this module
for _, module in pairs(script:GetChildren()) do
	Cam[module.Name] = require(module)
end

-- Sets a unique custom camera type if it exists
function Cam:setCameraType(camType: string, ...)
	if self.currentType ~= camType and camType == "Default" then
		self:returnToPlayer()
		return
	end
	if self[camType] then 
		self.currentType = camType
		self[camType](self, ...)
		camTypeChanged:Fire(camType)
	end
end

-- Sets the camera to a fixed position, with a given rotation or looking at the given lookAt Vector3
function Cam:fixedPoint(pos, rotation, lookAt)
	local camCF = Camera.CFrame
	self.prevCamCFrame = camCF
	self.prevCamDist = camCF.Position - player.Character.Head.Position

	if not pos and not rotation and not lookAt then
		Camera.CameraType = Enum.CameraType.Scriptable
		return
	end

	if (not pos or typeof(pos) == "Vector3") and (not rotation or typeof(rotation) == "Vector3") and (not lookAt or typeof(lookAt) == "Vector3") then
		Camera.CameraType = Enum.CameraType.Scriptable
		local newCF
		if lookAt then
			newCF = CFrame.lookAt((pos and pos) or camCF.Position, (lookAt and lookAt) or (camCF * CFrame.new(camCF.LookVector)).Position)
		elseif rotation then
			pos = (pos and pos) or camCF.Position
			newCF = CFrame.new(pos.X, pos.Y, pos.Z) * CFrame.Angles(rotation.X, rotation.Y, rotation.Z)
		else
			pos = (pos and pos) or camCF.Position
			local _, _, _, r00, r01, r02, r10, r11, r12, r20, r21, r22 = camCF:GetComponents()
			newCF = CFrame.new(pos.X, pos.Y, pos.Z, r00, r01, r02, r10, r11, r12, r20, r21, r22)
		end
		Camera.CFrame = newCF
	end
end

-- Returns the camera to the player
function Cam:returnToPlayer()
	Camera.CFrame = self.prevCamCFrame
	Camera.CameraType = Enum.CameraType.Custom
	Camera.CameraSubject = player.Character:FindFirstChild("Humanoid")
	self.currentType = "Default"
	camTypeChanged:Fire("Default")
end

return Cam
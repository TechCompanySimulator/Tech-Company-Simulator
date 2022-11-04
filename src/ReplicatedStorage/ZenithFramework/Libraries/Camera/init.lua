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

-- Returns the camera to the player, with an optional argument to tween, and a tween duration
function Cam:returnToPlayer(tween, tweenDuration)
	if self.prevCamCFrame then
		Camera.CFrame = self.prevCamCFrame
		self.prevCamCFrame = nil
	end
	Camera.CameraType = Enum.CameraType.Custom
	Camera.CameraSubject = player.Character:FindFirstChild("Humanoid")
	self.currentType = "Default"
	camTypeChanged:Fire("Default")
end

return Cam
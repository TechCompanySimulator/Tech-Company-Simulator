local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

if RunService:IsServer() then return {} end

local Camera = workspace.CurrentCamera

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local camTypeChanged = getDataStream("CamTypeChanged", "BindableEvent")

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

Cam:setCameraType("BuildMode", CFrame.new(0, 2, 0))

-- Returns the camera to the player, with an optional argument to tween, and a tween duration
function Cam:returnToPlayer(tween, tweenDuration)
	if self.prevCamCFrame then
		Camera.CFrame = self.prevCamCFrame
		self.prevCamCFrame = nil
	end
	Camera.CameraType = Enum.CameraType.Custom
	self.currentType = "Default"
	camTypeChanged:Fire("Default")
end

return Cam
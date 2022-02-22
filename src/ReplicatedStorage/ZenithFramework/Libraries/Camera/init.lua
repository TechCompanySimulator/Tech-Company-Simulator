local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

if RunService:IsServer() then return {} end

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Cam = {
	currentType = "Normal";
}

-- Compile all of the camera modes into this module
for _, module in pairs(script:GetChildren()) do
	Cam[module.Name] = require(module)
end

-- Sets a unique custom camera type if it exists
function Cam:setCameraType(camType: string, ...)
	if self.currentType ~= camType and camType == "Normal" then
		self:returnToPlayer()
		return
	end
	if self[camType] then 
		self[camType](self, ...)
		self.currentType = camType
	end
end

-- Returns the camera to the player, with an optional argument to tween, and a tween duration
function Cam:returnToPlayer(tween, tweenDuration)
	Camera.CFrame = self.prevCamCFrame
	Camera.CameraType = Enum.CameraType.Custom
	self.currentType = "Normal"
end

return Cam
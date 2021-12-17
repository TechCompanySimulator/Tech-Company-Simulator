-- Useful functions to do with the Players mouse
-- Author: TheM0rt0nator

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService  = game:GetService("RunService")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Raycast = loadModule("Raycast")

local Mouse = {}

if RunService:IsClient() then
	function Mouse.findHitWithWhitelist(mouse, filterInstances, distance)
		local camera = workspace.CurrentCamera
		local unitRay = camera:ScreenPointToRay(mouse.X, mouse.Y, 0)
		local raycastResult = Raycast.new(filterInstances, "Whitelist", unitRay.Origin, unitRay.Direction, distance)
		return raycastResult and raycastResult.Instance
	end
end

return Mouse
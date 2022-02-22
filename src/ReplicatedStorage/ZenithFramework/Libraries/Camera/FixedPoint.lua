local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

return function(self, pos, rotation, lookAt)
	local camCF = Camera.CFrame
	self.prevCamCFrame = camCF
	self.prevCamDist = camCF.Position - Player.Character.Head.Position
	if not pos and not rotation and not lookAt then Camera.CameraType = Enum.CameraType.Scriptable return end
	if (not pos or typeof(pos) == "Vector3") and (not rotation or typeof(rotation) == "Vector3") and (not lookAt or typeof(lookAt) == "Vector3") then
		Camera.CameraType = Enum.CameraType.Scriptable
		local newCF 
		if lookAt then
			newCF = CFrame.lookAt((pos and pos) or camCF.Position, (lookAt and lookAt) or (camCF * CFrame.new(camCF.LookVector)).Position)
		elseif rotation then
			local pos = (pos and pos) or camCF.Position
			newCF = CFrame.new(pos.X, pos.Y, pos.Z) * CFrame.Angles(rotation.X, rotation.Y, rotation.Z)
		else
			local pos = (pos and pos) or camCF.Position
			local _, _, _, r00, r01, r02, r10, r11, r12, r20, r21, r22 = camCF:GetComponents()
			newCF = CFrame.new(pos.X, pos.Y, pos.Z, r00, r01, r02, r10, r11, r12, r20, r21, r22)
		end
		Camera.CFrame = newCF
	end
end
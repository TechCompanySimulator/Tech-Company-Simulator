-- Radial camera mode which is centered on one point and you can radially move the camera around this point and zoom in / out
local Camera = workspace.CurrentCamera

return function(self, focus)
	if typeof(focus) == "Vector3" then
		
	elseif focus:IsA("BasePart") then
		Camera.CameraType = Enum.CameraType.Custom
		Camera.CameraSubject = focus
	end
end
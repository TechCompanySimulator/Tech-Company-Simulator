-- Radial camera mode which is centered on one point and you can radially move the camera around this point and zoom in / out
local Camera = workspace.CurrentCamera

return function(_, focus)
	if focus:IsA("BasePart") then
		Camera.CameraType = Enum.CameraType.Custom
		Camera.CameraSubject = focus
	end
end
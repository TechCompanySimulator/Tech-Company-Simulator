local InstanceUtil = {}

-- Finds the first ancestor which is under the given instance
function InstanceUtil.findFirstAncestorUnderInstance(child : Instance, instance : Instance) : Instance?
	if not child:IsDescendantOf(instance) then return end

	while true do
		if not child or not child.Parent then return end
		
		local parent = child.Parent
		if parent == instance then
			return child
		end

		child = parent
		task.wait()
	end
end

function InstanceUtil.toggleModelCol(model : Instance, col : Color3?, toggled : boolean) : nil
	for _, part in model:GetDescendants() do
		if not part:IsA("BasePart") then continue end

		if toggled then
			part:SetAttribute("OriginalColor", part.Color)
			part.Color = col
		else
			part.Color = part:GetAttribute("OriginalColor")
			part:SetAttribute("OriginalColor", nil)
		end
	end
end

return InstanceUtil
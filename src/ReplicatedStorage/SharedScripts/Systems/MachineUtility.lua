local MachineUtility = {
	METAL_PROPERTIES = {
		Material = Enum.Material.Metal;
		Color = Color3.fromRGB(163, 162, 165);
	};
	CHROME_PROPERTIES = {
		Material = Enum.Material.SmoothPlastic;
		Color = Color3.fromRGB(99, 95, 98);
		Reflectance = 0.4;
	};
	CHROME_DETAILING_PROPERTIES = {
		Color = Color3.fromRGB(255, 176, 0);
	};
}

function MachineUtility.getPlayerFolder(player : Player) : Instance
	-- TODO: Implement

	return workspace
end

-- Updates the physical properties of a model, based on their name and the properties passed in
function MachineUtility.updatePropertiesByName(model : Model, partPropertiesMap : table) : nil
	for _, obj in model:GetDescendants() do
		if not partPropertiesMap[obj.Name] or not obj:IsA("BasePart") then continue end

		for property, value in partPropertiesMap[obj.Name] do
			obj[property] = value
		end
	end
end

function MachineUtility.upgradeControlPanel(model : Model) : nil

end


return MachineUtility
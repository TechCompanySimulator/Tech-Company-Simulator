local shopConfig = {
	categories = {
		furniture = {
			layoutOrder = 1;
			displayName = "Furniture";
		};
	};
}

for _, module in pairs(script:GetChildren()) do
	shopConfig[module.Name] = require(module)
end

return shopConfig
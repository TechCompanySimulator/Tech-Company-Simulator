local settings = {}

-- Grab all the settings tables and put them into this main table
for _, module in ipairs(script:GetChildren()) do
	settings[module.Name] = require(module)
end

return settings
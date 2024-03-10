local NPCSystem = {
	NPCs = {};
}

function NPCSystem.initiate()
	for _, module in script.NPC.NPCs:GetChildren() do
		NPCSystem.NPCs[module.Name] = require(module.new())
	end
end

return NPCSystem
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local CollisionGroups = loadModule("CollisionGroups")

local CharacterManager = {}

-- Function to run when the players character loads
function CharacterManager.characterAdded(char)
	CollisionGroups.assignGroup(char, "Player")
end

-- Function to run when the player first joins the game
function CharacterManager.playerAdded(player)
	if not player.Character then
		player.CharacterAdded:Wait()
	end
	CharacterManager.characterAdded(player.Character)
	player.CharacterAdded:Connect(CharacterManager.characterAdded)
end

Players.PlayerAdded:Connect(CharacterManager.playerAdded)

return CharacterManager
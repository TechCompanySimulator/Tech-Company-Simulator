local ProximityPromptService = game:GetService("ProximityPromptService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

if RunService:IsServer() then return {} end

local ProximityManager = {}
ProximityManager.__index = ProximityManager
ProximityManager.enabled = {}

function ProximityManager:Enable(groupName)
	ProximityManager.enabled[groupName] = nil
	ProximityManager._update()
end

function ProximityManager:Disable(groupName)
	ProximityManager.enabled[groupName] = false
	ProximityManager._update()
end

function ProximityManager._update()
	local isEnabled = true

	for _, groupEnabled in pairs(ProximityManager.enabled) do
		if groupEnabled == false then
			isEnabled = false
			break
		end
	end

	if ProximityPromptService.Enabled ~= isEnabled then
		ProximityPromptService.Enabled = isEnabled
	end
end

function ProximityManager.reset()
	ProximityManager.enabled = {}

	if not ProximityPromptService.Enabled then
		ProximityPromptService.Enabled = true
	end
end

Players.LocalPlayer.CharacterAdded:Connect(ProximityManager.reset)

return ProximityManager
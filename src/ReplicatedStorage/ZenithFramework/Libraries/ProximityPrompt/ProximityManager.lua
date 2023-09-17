local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local RunService = game:GetService("RunService")

if RunService:IsServer() then return {} end

local ProximityManager = {
	enabled = {}
}
ProximityManager.__index = ProximityManager

function ProximityManager:enable(groupName : string) : nil
	ProximityManager.enabled[groupName] = nil
	ProximityManager:update()
end

function ProximityManager:disable(groupName : string) : nil
	ProximityManager.enabled[groupName] = false
	ProximityManager:update()
end

function ProximityManager:update() : nil
	local isEnabled = true

	for _, groupEnabled in ProximityManager.enabled do
		if groupEnabled == false then
			isEnabled = false
			break
		end
	end

	if ProximityPromptService.Enabled ~= isEnabled then
		ProximityPromptService.Enabled = isEnabled
	end
end

function ProximityManager:reset() : nil
	ProximityManager.enabled = {}

	if not ProximityPromptService.Enabled then
		ProximityPromptService.Enabled = true
	end
end

Players.LocalPlayer.CharacterAdded:Connect(ProximityManager.reset)

return ProximityManager
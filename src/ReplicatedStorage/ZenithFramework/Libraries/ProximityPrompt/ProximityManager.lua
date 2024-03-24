local ProximityPromptService = game:GetService("ProximityPromptService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

if RunService:IsServer() then return {} end

local CustomPrompt = require(script.Parent.CustomPrompt)

local ProximityManager = {}
ProximityManager.enabled = {}
ProximityManager.prompts = {}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

function ProximityManager.initiate()
	ProximityPromptService.PromptShown:Connect(function(prompt, inputType)
		if prompt.Style == Enum.ProximityPromptStyle.Default then
			return
		end

		local gui = playerGui:WaitForChild("CustomProximityPrompts", 4)
		if not gui then warn("CustomProximityPrompts folder not found.") return end

		local cleanupFunction = CustomPrompt(prompt, inputType, gui, ProximityManager)

		prompt.PromptHidden:Wait()

		cleanupFunction()
	end)
end

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

player.CharacterAdded:Connect(ProximityManager.reset)

return ProximityManager
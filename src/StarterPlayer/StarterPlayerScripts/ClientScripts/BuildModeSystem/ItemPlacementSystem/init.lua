local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Mouse = loadModule("Mouse")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local placementAsset

local GRID_SIZE = 1

local ItemPlacementSystem = {}

function ItemPlacementSystem.startPlacement(category, variation, itemId)
	print(category, itemId)
	local categoryItems = ReplicatedStorage.Assets:FindFirstChild(category)
	if not categoryItems then return end

	local variationItems = categoryItems:FindFirstChild(variation)
	if not variationItems then return end

	local asset = variationItems:FindFirstChild(itemId)
	if not asset then return end

	local assetClone = asset:Clone()
	assetClone.Parent = workspace
	placementAsset = assetClone

	local origin = 
	
	RunService:BindToRenderStep("ItemPlacement", Enum.RenderPriority.Camera.Value, function()
		local hit = Mouse.findHitWithWhitelist(mouse, {
			workspace.Plots
		}, 100)

		if hit and hit.Instance then
			assetClone:PivotTo(CFrame.new(hit.Position))
		end
	end)
end

function ItemPlacementSystem.stopPlacement()
	RunService:UnbindFromRenderStep("ItemPlacement")
	if placementAsset then
		placementAsset:Destroy()
		placementAsset = nil
	end
end

return ItemPlacementSystem
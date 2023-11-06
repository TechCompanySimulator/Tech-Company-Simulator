local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Mouse = loadModule("Mouse")
local PlotSelection = loadModule("PlotSelection")
local Maid = loadModule("Maid")
local Tween = loadModule("Tween")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local placementMaid = Maid.new()
local placementAsset

local GRID_INCREMENT = 2
local ROTATE_INCREMENT = math.rad(45)

local ItemPlacementSystem = {}

-- This function checks if a given point is inside a rotated rectangle.
-- If it's not, it will return the closest point inside the bounds of the rectangle.
local function constrainToRectangle(plotPart, pos)
	-- Assuming plotCFrame is the CFrame of the plot part in world space
	-- and worldPoint is the position in world space we want to constrain
	local plotCFrame = plotPart.CFrame
	local halfPlotSize = plotPart.Size * 0.5

	-- Convert the world point to the plot's local space
	local localPoint = plotCFrame:ToObjectSpace(CFrame.new(pos)).Position

	-- Clamp the local point within the plot bounds
	local clampedLocalX = math.clamp(localPoint.X, -halfPlotSize.X, halfPlotSize.X)
	local clampedLocalZ = math.clamp(localPoint.Z, -halfPlotSize.Z, halfPlotSize.Z)
	local clampedLocalPoint = Vector3.new(clampedLocalX, localPoint.Y, clampedLocalZ)

	-- Convert the clamped local point back to world space
	return plotCFrame:ToWorldSpace(CFrame.new(clampedLocalPoint)).Position
end

function ItemPlacementSystem.startPlacement(category, variation, itemId)
	if not PlotSelection.myPlot then return end

	print(category, itemId)
	local categoryItems = ReplicatedStorage.Assets:FindFirstChild(category)
	if not categoryItems then return end

	local variationItems = categoryItems:FindFirstChild(variation)
	if not variationItems then return end

	local asset = variationItems:FindFirstChild(itemId)
	if not asset then return end

	mouse.TargetFilter = workspace.PlacementGhosts

	local assetClone = asset:Clone()
	assetClone.Parent = workspace.PlacementGhosts
	placementAsset = assetClone

	for _, part in assetClone:GetDescendants() do
		if not part:IsA("BasePart") then continue end

		part.Transparency = math.max(part.Transparency, 0.5)
	end

	local plotPart = PlotSelection.myPlot
	local currentRotation = plotPart.CFrame - plotPart.CFrame.Position
	local halfPrimPartSize = assetClone.PrimaryPart.Size / 2
	local origin = plotPart.CFrame * CFrame.new(-plotPart.Size.X / 2, 0, -plotPart.Size.Z / 2)
	print(halfPrimPartSize)
	local targetCF
	plotPart.Texture.Transparency = 0.7
	
	RunService:BindToRenderStep("ItemPlacement", Enum.RenderPriority.Camera.Value, function()
		local hit = Mouse.findHitWithWhitelist(mouse, {
			PlotSelection.myPlot;
		}, 100)

		local freePos
		if hit and hit.Instance then
			freePos = hit.Position
		elseif mouse.Hit then
			local pos = mouse.Hit.Position
			freePos = constrainToRectangle(plotPart, pos)
		end

		if freePos then
			-- Calculate the offset from the origin
			local offset = freePos - origin.Position

			-- Snap the offset to the grid
			local snappedOffsetX = GRID_INCREMENT * math.round(offset.X / GRID_INCREMENT)
			local snappedOffsetZ = GRID_INCREMENT * math.round(offset.Z / GRID_INCREMENT)
	
			-- Calculate the new snapped position
			local snappedPosition = Vector3.new(
				origin.Position.X + snappedOffsetX,
				origin.Y, -- Assuming you don't want to snap the Y position
				origin.Position.Z + snappedOffsetZ
			)

			local newCF = CFrame.new(snappedPosition) * currentRotation
			if targetCF ~= newCF then
				targetCF = newCF
				local newTween = Tween.new(
					assetClone:GetPivot(), 
					newCF,
					TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
					function(val)
						-- Update the asset clone's position, snapped to the grid
						assetClone:PivotTo(val)
					end
				)
				newTween:play()
			end
		end
	end)

	placementMaid:GiveTask(UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Keyboard or input.KeyCode ~= Enum.KeyCode.R then return end
		
		currentRotation *= CFrame.Angles(0, ROTATE_INCREMENT, 0)
	end))
end

function ItemPlacementSystem.stopPlacement()
	mouse.TargetFilter = nil
	RunService:UnbindFromRenderStep("ItemPlacement")
	if placementAsset then
		placementAsset:Destroy()
		placementAsset = nil
	end

	if PlotSelection.myPlot then
		PlotSelection.myPlot.Texture.Transparency = 1
	end
end

return ItemPlacementSystem
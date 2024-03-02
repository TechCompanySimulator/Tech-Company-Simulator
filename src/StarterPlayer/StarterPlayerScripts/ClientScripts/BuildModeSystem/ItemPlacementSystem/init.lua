local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Mouse = loadModule("Mouse")
local PlotSelection = loadModule("PlotSelection")
local Maid = loadModule("Maid")
local Tween = loadModule("Tween")
local PlotUtility = loadModule("PlotUtility")
local CurrencyManager = loadModule("CurrencyManager")

local placeItemFunc = getDataStream("PlaceItem", "RemoteFunction")

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
	local plotPart = PlotSelection.myPlot
	if not plotPart then return end

	local asset = PlotUtility.getAsset(category, variation, itemId)
	if not asset then return end

	local itemConfig = PlotUtility.getItemConfig(category:lower(), variation, itemId)
	if not itemConfig then return end

	if not CurrencyManager:hasAmount(player, itemConfig.price.currency, itemConfig.price.amount) then return end

	mouse.TargetFilter = workspace.MouseTargetFilter

	local assetClone = asset:Clone()
	assetClone.Parent = workspace.MouseTargetFilter.PlacementGhosts
	placementAsset = assetClone

	for _, part in assetClone:GetDescendants() do
		if not part:IsA("BasePart") then continue end

		part.Transparency = math.max(part.Transparency, 0.5)
		part.CollisionGroup = "PlacementGhost"
	end

	local currentRotation = plotPart.CFrame - plotPart.CFrame.Position
	local origin = plotPart.CFrame * CFrame.new(-plotPart.Size.X / 2, 0, -plotPart.Size.Z / 2)
	local targetCF
	plotPart.Texture.Transparency = 0.7

	local lastCheckedCF
	local currentTween
	
	RunService:BindToRenderStep("ItemPlacement", Enum.RenderPriority.Camera.Value, function()
		local hit = Mouse.findHitWithWhitelist(mouse, {
			plotPart;
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
			local didFinishTween = false
			if targetCF ~= newCF then
				if currentTween then
					currentTween:reset()
				end

				targetCF = newCF
				currentTween = Tween.new(
					assetClone:GetPivot(), 
					newCF,
					TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
					function(val)
						-- Update the asset clone's position, snapped to the grid
						assetClone:PivotTo(val)
						didFinishTween = val == newCF
					end
				)
				currentTween:play(true)
			end

			if didFinishTween and lastCheckedCF ~= newCF then
				lastCheckedCF = newCF
				local isTouching = false
				local placedItems = workspace.PlacedItems:FindFirstChild(plotPart.Name)
				local overlapParams = OverlapParams.new()
				overlapParams.FilterDescendantsInstances = placedItems and placedItems:GetChildren() or {}
				overlapParams.FilterType = Enum.RaycastFilterType.Include

				for _, part in assetClone.Touch:GetChildren() do
					local touchingParts = workspace:GetPartsInPart(part, overlapParams)
					print(touchingParts)
					for _, touchingPart in touchingParts do
						if touchingPart:IsDescendantOf(assetClone) then continue end

						isTouching = true
						break
					end

					if isTouching then break end
				end

				if isTouching and not assetClone:GetAttribute("IsTouching") then
					assetClone:SetAttribute("IsTouching", true)

					for _, part in assetClone:GetDescendants() do
						if not part:IsA("BasePart") then continue end

						part:SetAttribute("OriginalColor", part.Color)
						part.Color = Color3.fromRGB(255, 0, 0)
					end
				elseif not isTouching and assetClone:GetAttribute("IsTouching") then
					assetClone:SetAttribute("IsTouching", false)

					for _, part in assetClone:GetDescendants() do
						if not part:IsA("BasePart") then continue end

						part.Color = part:GetAttribute("OriginalColor")
					end
				end
			end
		end
	end)

	-- Rotate the asset when the user presses R
	placementMaid:GiveTask(UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Keyboard or input.KeyCode ~= Enum.KeyCode.R then return end
		
		currentRotation *= CFrame.Angles(0, ROTATE_INCREMENT, 0)
	end))

	-- Cancel placement when pressing C
	placementMaid:GiveTask(UserInputService.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.Keyboard or input.KeyCode ~= Enum.KeyCode.C then return end
		
		ItemPlacementSystem.stopPlacement()
	end))

	task.defer(function()
		if not placementAsset or not placementAsset.Parent then return end

		-- When the player clicks, ask the server to place the asset
		placementMaid:GiveTask(UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
			
			local objectSpace = PlotSelection.myPlot.CFrame:ToObjectSpace(placementAsset.PrimaryPart.CFrame)
			local success = placeItemFunc:InvokeServer(category, variation, itemId, objectSpace)
			if not success then return end

			ItemPlacementSystem.stopPlacement()
		end))
	end)
end

function ItemPlacementSystem.stopPlacement()
	mouse.TargetFilter = nil
	RunService:UnbindFromRenderStep("ItemPlacement")
	if placementAsset then
		placementAsset:Destroy()
		placementAsset = nil
	end

	placementMaid:DoCleaning()

	if PlotSelection.myPlot then
		PlotSelection.myPlot.Texture.Transparency = 1
	end
end

return ItemPlacementSystem
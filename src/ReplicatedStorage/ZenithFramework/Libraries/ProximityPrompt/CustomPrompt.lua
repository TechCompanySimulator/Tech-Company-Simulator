local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Maid = loadModule("Maid")
local Tween = loadModule("Tween")

local TEMPLATE_FOLDER = ReplicatedStorage.Assets.ReactTemplates.CustomProximityPrompts
local TWEEN_DURATION = 0.1

local function enterTween(frame, size)
	local tween = Tween.new(
		frame.Size, 
		size, 
		TweenInfo.new(TWEEN_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
		function(val)
			frame.Size = val
		end
	)

	tween:play()

	return tween
end

local function exitTween(frame)
	local tween = Tween.new(
		frame.Size, 
		UDim2.fromScale(0, 0), 
		TweenInfo.new(TWEEN_DURATION, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
		function(val)
			frame.Size = val
		end
	)

	tween:play(true)
end

local function createUI(prompt, gui)
	local newPrompt = Instance.new("BillboardGui")
	newPrompt.Name = "Prompt"
	newPrompt.Size = UDim2.fromOffset(200, 75)
	newPrompt.Active = true
	newPrompt.AlwaysOnTop = true

	local promptStyle = prompt:GetAttribute("PromptStyle") or "Default"
	local template = TEMPLATE_FOLDER:FindFirstChild(promptStyle)
	if not template then warn("No template found for prompt style ", promptStyle) return end

	local promptFrame = template:Clone()
	promptFrame.Keycode.TextLabel.Text = prompt.KeyboardKeyCode.Name
	promptFrame.ObjectText.Text = prompt.ObjectText
	promptFrame.ActionText.Text = prompt.ActionText
	promptFrame.Name = "PromptFrame"
	promptFrame.Parent = newPrompt

	local size = promptFrame.Size
	promptFrame.Size = UDim2.fromScale(0, 0)

	newPrompt.Adornee = prompt.Parent
	newPrompt.Parent = gui

	if prompt.ClickablePrompt then
		local button = Instance.new("TextButton")
		button.Name = "ClickableButton"
		button.Size = UDim2.fromScale(1, 1)
		button.BackgroundTransparency = 1
		button.Text = ""
		button.TextTransparency = 1
		button.ZIndex = 2
		button.Parent = newPrompt
	end

	local enterTween = enterTween(promptFrame, size)

	return newPrompt, enterTween
end

local function setupInput(prompt, inputType, ui, maid, manager)
	local currentProgress = prompt:GetAttribute("Progress") or 0
	local holdDuration = prompt.HoldDuration
	local currentProgressTween
	local isHeld = false

	ui.PromptFrame.Progress.Size = UDim2.new(currentProgress, 0, ui.PromptFrame.Progress.Size.Y.Scale, ui.PromptFrame.Progress.Size.Y.Offset)

	local function began()
		if isHeld then return end

		isHeld = true

		local yScale = ui.PromptFrame.Progress.Size.Y.Scale
		local yOffset = ui.PromptFrame.Progress.Size.Y.Offset

		ui.PromptFrame.Keycode.TextLabel.Text = "<b>" .. ui.PromptFrame.Keycode.TextLabel.Text .. "</b>"
		local saveProgress = prompt:GetAttribute("SaveProgress")

		if currentProgressTween then
			currentProgressTween:reset()
		end

		currentProgressTween = Tween.new(
			currentProgress, 
			1, 
			TweenInfo.new(holdDuration * (1 - currentProgress), Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), 
			function(val, tween)
				if not ui or not ui:FindFirstChild("PromptFrame") or not ui.Parent then
					tween:reset()
					return
				end

				ui.PromptFrame.Progress.Size = UDim2.new(val, 0, yScale, yOffset)
				currentProgress = val
				if saveProgress then
					prompt:SetAttribute("Progress", val)
				end
			end
		)

		currentProgressTween:play(true)
		if currentProgress < 1 then return end

		if prompt.Style == Enum.ProximityPromptStyle.Custom and manager and manager.prompts[prompt] and manager.prompts[prompt].connectedFunctions then
			for _, func in manager.prompts[prompt].connectedFunctions do
				task.spawn(func)
			end
		end
	end

	local function ended()
		if not isHeld then return end

		isHeld = false

		local yScale = ui.PromptFrame.Progress.Size.Y.Scale
		local yOffset = ui.PromptFrame.Progress.Size.Y.Offset
		ui.PromptFrame.Keycode.TextLabel.Text = prompt.KeyboardKeyCode.Name

		if currentProgressTween then
			currentProgressTween:reset()
		end

		if not prompt:GetAttribute("SaveProgress") then
			currentProgressTween = Tween.new(
				currentProgress, 
				0, 
				TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), 
				function(val, tween)
					if not ui or not ui:FindFirstChild("PromptFrame") or not ui.Parent then
						tween:reset()
						return
					end

					ui.PromptFrame.Progress.Size = UDim2.new(val, 0, yScale, yOffset)
				end
			)

			currentProgressTween:play()
			currentProgress = 0
		end
	end

	maid:GiveTask(UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode ~= prompt.KeyboardKeyCode then return end

		began()
	end))

	maid:GiveTask(UserInputService.InputEnded:Connect(function(input)
		if input.KeyCode ~= prompt.KeyboardKeyCode then return end

		ended()
	end))

	if inputType == Enum.ProximityPromptInputType.Touch or prompt.ClickablePrompt then 
		maid:GiveTask(ui.ClickableButton.InputBegan:Connect(function(input)
			if
				(
					input.UserInputType == Enum.UserInputType.Touch
					or input.UserInputType == Enum.UserInputType.MouseButton1
				) and input.UserInputState ~= Enum.UserInputState.Change
			then 
				began()
			end
		end))

		maid:GiveTask(ui.ClickableButton.InputEnded:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.Touch
				or input.UserInputType == Enum.UserInputType.MouseButton1
			then 
				ended()
			end
		end))
	end
end

return function(prompt, inputType, gui, manager)
	local promptMaid = Maid.new()
	local promptUI, enterTween = createUI(prompt, gui)
	setupInput(prompt, inputType, promptUI, promptMaid, manager)

	return function()
		promptMaid:doCleaning()
		if enterTween then
			enterTween:reset()
		end

		exitTween(promptUI.PromptFrame)
		promptUI:Destroy()
	end
end
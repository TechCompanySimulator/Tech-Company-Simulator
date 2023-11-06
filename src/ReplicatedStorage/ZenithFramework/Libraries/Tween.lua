local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local LERP_TYPES = {
	["CFrame"] = true;
	["Vector3"] = true;
	["Vector2"] = true;
	["Color3"] = true;
	["UDim"] = true;
	["UDim2"] = true;
}

local Tween = {}
Tween.__index = Tween

function Tween.new(start, finish, tweenInfo, callback)
	local self = setmetatable({}, Tween)

	self.start = start
	self.finish = finish
	self.tweenInfo = tweenInfo
	self.callback = callback
	self.id = HttpService:GenerateGUID(false)

	self.running = false

	return self
end

function Tween:play(shouldYield)
	if self.running then return end
	self.running = true

	self.startTime = tick()
	local duration = self.tweenInfo.Time
	local start = self.start
	local finish = self.finish
	local callback = self.callback
	local finished = false

	RunService:BindToRenderStep(self.id, Enum.RenderPriority.Input.Value, function()
		local currentTime = tick() - self.startTime
		local alpha = currentTime / duration
		local value = TweenService:GetValue(alpha, self.tweenInfo.EasingStyle, self.tweenInfo.EasingDirection)
		if alpha >= 1 then
			if not finished then
				finished = true
				RunService:UnbindFromRenderStep(self.id)
				self.running = false
				callback(finish)
			end
		else
			local currentVal 
			if typeof(self.start) == "number" then
				currentVal = value
			elseif LERP_TYPES[typeof(self.start)] then
				currentVal = start:Lerp(finish, value)
			end

			callback(currentVal, self)
		end
	end)

	if shouldYield then
		while self.running do
			RunService.Heartbeat:Wait()
		end
	end
end

function Tween:reset()
	self.running = false
	RunService:UnbindFromRenderStep(self.id)
end

return Tween
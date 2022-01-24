

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local loadModule = table.unpack(require(ReplicatedStorage.ZenithFramework))

local Maid = loadModule("Maid")

local AcceptedValueTypes = {
	["number"] = true;
	["Vector2"] = true;
	["Vector3"] = true;
	["CFrame"] = true;
	["UDim2"] = true;
	["Color3"] = true;
}

local Tween = {}
Tween.__index = Tween

local function lerpNumber(startValue : number, endValue : number, alpha : number)
	return startValue + alpha * (endValue - startValue)
end

function Tween.new(startValue : any, endValue : any, tweenInfo : TweenInfo, callback)
	assert(AcceptedValueTypes[typeof(startValue)], "Tween initial value must be of an accepted type.")
	assert(typeof(startValue) == typeof(endValue), "Tween start and end values must be of the same type.")
	assert(typeof(tweenInfo) == "TweenInfo", "Tween TweenInfo argument is invalid.")
	assert(typeof(callback) == "function", "Callback must be a valid function.")

	local self = setmetatable({}, Tween)

	self._maid =  Maid.new()
	self.callback = callback

	self.startValue = startValue
	self.endValue = endValue
	self._currentValue = self.startValue

	self.tweenInfo = tweenInfo
	self.easingDir = tweenInfo.EasingDirection
	self.easingStyle = tweenInfo.EasingStyle
	self.duration = tweenInfo.Time
	self.delayTime = tweenInfo.DelayTime
	self.repeatCount = tweenInfo.RepeatCount
	self.reverses = tweenInfo.Reverses
end

function Tween:play(newThread)
	if newThread then
		task.spawn(function()
			self:_runTween()
		end)
	else
		self:_runTween()
	end
end

function Tween:pause()
	self._isPlaying = false
end

function Tween:reset()
	self._isPlaying = false
	self._currentCount = 0
	self._reverse = 0
	self._time = 0
	self._currentValue = self.startValue
end

function Tween:_runTween()
	self._isPlaying = true

	if self.repeatCount == -1 then
		while self._isPlaying do
			self:_step()
		end
	else
		for i = self._currentCount, self.repeatCount do
			if self._isPlaying then
				self._currentCount = i

				self:_step()
			end
		end
	end

	self:reset()
end

function Tween:_step()
	if not self._isPlaying then return end

	if self.delayTime > 0 then
		task.wait(self.delayTime)
	end

	if not self._isPlaying then return end

	for r = self._reverse, (self.reverses and 1) or 0 do
		self._reverse = r

		local _currentTime = os.time()
		local delta = 1/60

		while self._time < self.duration do
			self._time = self._time + delta

			local alpha = TweenService:GetValue((r == 1 and 1 - (self._time / self.duration)) or self._time / self.duration, self.easingStyle, self.easingDir)

			if typeof(self.startValue) == "number" then
				self._currentValue = lerpNumber(self.startValue, self.endValue, alpha)
			else
				self._currentValue = self.startValue:lerp(self.endValue, alpha)
			end

			self.callback(self._currentValue, self)

			RunService.Heartbeat:Wait()

			if not self._isPlaying then return end

			local currentTime = os.time()
			delta = (currentTime - _currentTime)
			_currentTime = currentTime
		end

		self._reverse = 0
		self._time = 0
		self._currentValue = (r == 1 and self.startValue) or self.endValue
		self.callback(self._currentValue, self)
	end
end

return Tween
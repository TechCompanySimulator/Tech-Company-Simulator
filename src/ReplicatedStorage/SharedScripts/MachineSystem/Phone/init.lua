local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local loadModule, getDataStream = table.unpack(require(ReplicatedStorage.ZenithFramework))

local String = loadModule("String")

local Phone = {
	buildOptions = {};
	components = 3;
}

Phone.speedUpgrades = {
	[1] = {
		currency = "Coins";
		amount = 45;
	};
	[2] = {
		currency = "Coins";
		amount = 70;
	};
	[3] = {
		currency = "Coins";
		amount = 135;
	};
	[4] = {
		currency = "Coins";
		amount = 400;
	};
	[5] = {
		currency = "Coins";
		amount = 2500;
	};
}

Phone.qualityUpgrades = {
	[1] = {
		currency = "Coins";
		amount = 15;
	};
	[2] = {
		currency = "Coins";
		amount = 25;
	};
	[3] = {
		currency = "Coins";
		amount = 90;
	};
	[4] = {
		currency = "Coins";
		amount = 210;
	};
	[5] = {
		currency = "Coins";
		amount = 5000;
	};
	[6] = {
		currency = "Coins";
		amount = 15000;
	};
	[7] = {
		currency = "Coins";
		amount = 50000;
	};
	[8] = {
		currency = "Coins";
		amount = 100000;
	};
	[9] = {
		currency = "Coins";
		amount = 200000;
	};
	[10] = {
		currency = "Gems";
		amount = 30;
	};
	[11] = {
		currency = "Gems";
		amount = 40;
	};
	[12] = {
		currency = "Gems";
		amount = 50;
	};
	[13] = {
		currency = "Gems";
		amount = 60;
	};
}

function Phone.injectTweenInfo(phoneModel, buildStage)
	local tweenInfo = {
		[1] = {
			duration = 3;
			object = phoneModel.Case;
			cframe = function(i)
				return CFrame.new(0, i, 0) * CFrame.Angles(0, 0, i*math.pi/2)
			end;
			maxIndex = 3;
		};
		[2] = {
			duration = 3;
			object = phoneModel.Motherboard;
			cframe = function(i)
				return CFrame.new(0, i, 0) * CFrame.Angles(math.sin(6*i*math.pi/3)/2, 0, math.pi/2)
			end;
			maxIndex = 3;
		};
		[3] = {
			duration = 3;
			object = phoneModel.SIMCard;
			cframe = function(i)
				return CFrame.new(0, i, 0) * CFrame.Angles(-math.pi/2, 0, math.pi/2 + 4*i*math.pi/3)
			end;
			maxIndex = 3;
		};
	}
	return tweenInfo[buildStage]
end

function Phone.sendTweenInfo(phoneModel)
	return {
		duration = 3;
		object = phoneModel.Case;
		cframe = function(i)
			return CFrame.new(0, 0, 2.2*i)
		end;
		maxIndex = 3;
	}
end

for _, phone in pairs(script:GetChildren()) do
	Phone.buildOptions[String.getNumericCharacters(phone.Name)] = require(phone)
end

return Phone

--[[
local function CaseFunction()
	if machine.Values.BuildOption.Value == "" then return end
	local folder = repStorage.BuildItems.Phone:FindFirstChild(machine.Values.BuildOption.Value)
	local caseStart = machine.CaseStart.CFrame
	case = folder.Phone:Clone()
	case:SetPrimaryPartCFrame(caseStart)
	case.Parent = script.Parent.BuildItems
	for i = 0, 3, 0.05 do
		case:SetPrimaryPartCFrame(caseStart * CFrame.new(0,i,0) * CFrame.Angles(0,0,i*math.pi/2))
		wait()
	end
	machine.Values.InputsRequired.Value -= 1
	machineFunctions.assembleCheck(machine)
end

local function MotherboardFunction()
	if machine.Values.BuildOption.Value == "" then return end
	local folder = repStorage.BuildItems.Phone:FindFirstChild(machine.Values.BuildOption.Value)
	local motherboardStart = script.Parent.MotherboardStart.CFrame
	motherboard = folder.Motherboard:Clone()
	motherboard:SetPrimaryPartCFrame(motherboardStart)
	motherboard.Parent = script.Parent.BuildItems
	
	for i = 0, 3, 0.05 do
		motherboard:SetPrimaryPartCFrame(motherboardStart * CFrame.new(0,i,0) * CFrame.Angles(0.5*math.sin(6*math.pi*i/3),0,math.pi/2))
		wait()
	end
	machine.Values.InputsRequired.Value -= 1
	machineFunctions.assembleCheck(machine)
end


local function SIMFunction()
	if machine.Values.BuildOption.Value == "" then return end
	local folder = repStorage.BuildItems.Phone:FindFirstChild(machine.Values.BuildOption.Value)
	local simStart = script.Parent.SIMStart.CFrame
	sim = folder.SIMCard:Clone()
	sim:SetPrimaryPartCFrame(simStart)
	sim.Parent = script.Parent.BuildItems
	for i = 0, 3, 0.05 do
		sim:SetPrimaryPartCFrame(simStart * CFrame.new(0,i,0) * CFrame.Angles(-math.pi/2,0,math.pi/2 + 4*i*math.pi/3))
		wait()
	end
	machine.Values.InputsRequired.Value -= 1
	machineFunctions.assembleCheck(machine)
end

]]
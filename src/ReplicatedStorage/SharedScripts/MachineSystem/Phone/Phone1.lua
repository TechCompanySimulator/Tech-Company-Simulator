local Phone1 = {
	displayName = "RoBrick 1990"
}

-- if typeof(AssembleInfo[index]) == "function" then do the function only
-- If typeof(cframe) == "table" then move the index part
-- If not then assert object ~= nil
-- If typeof(cframe) == "Model/Instance" then Lerp

function Phone1.assembleTweenInfo(phoneModel)
	local tweenInfo = {
		[1] = {
			duration = 2;
			maxIndex = 2;
			object = phoneModel.Case;
			cframe = function(i)
				return CFrame.new(-1.3*i, 0.2*i, i) * CFrame.Angles(0, 0, 1.022*i*math.pi)
			end;
		};
		[2] = {
			duration = 2;
			maxIndex = 2;
			cframe = function(i)
				return {
					[phoneModel.Case.Main1] = CFrame.new(0, i, 0) * CFrame.Angles(math.sin(6*i*math.pi/3)/2, 0, math.pi/2);
					[phoneModel.Case.Screen] = CFrame.new(0, i/50, 0);
					[phoneModel.Motherboard] = CFrame.new(1.3*i, 0.2*i, 0) * CFrame.Angles(0, 0, -i*math.pi);
				}
			end;
		};
		[3] = {
			duration = 2;
			maxIndex = 2;
			cframe = function(i)
				return {
					[phoneModel.Motherboard] = phoneModel.Case.Main2.MotherboardFin;
					[phoneModel.SIMCard] = CFrame.new(i, 0.1*i + 1.5*math.sin(math.pi*i/2), 1.2*i) * CFrame.Angles(0, 0, i*math.pi);
				}
			end;
		};
		[4] = {
			duration = 0.5;
			object = phoneModel.SIMCard;
			cframe = phoneModel.Case.Main2.SIMFin;
		};
		[5] = function()
			phoneModel.Motherboard.Parent = phoneModel.Case.Main2
			phoneModel.SIMCard.Parent = phoneModel.Case.Main2
		end;
		[6] = {
			duration = 2;
			maxIndex = 2;
			cframe = function(i)
				return {
					[phoneModel.Case.Main2] = phoneModel.Case.Main1.Main2Fin;
					[phoneModel.Case.Screen] = CFrame.new(0, i/30, i/50) * CFrame.Angles(0, 0, i*math.pi/40);
				}
			end;
		};
		[7] = {
			duration = 1;
			maxIndex = 1;
			object = phoneModel.Case.Screen;
			cframe = phoneModel.Case.Main1.ScreenFin;
		};
	}

	return tweenInfo
end

return Phone1
local Phone2 = {
	displayName = "RoFlip 360"
}

function Phone2.sendTweenInfo(phoneModel)
	local tweenInfo = {
		[1] = {
			duration = 2;
			maxIndex = 2;
			object = phoneModel.Case;
			cframe = function(i)
				return CFrame.Angles(0, i*math.pi/4, 0) * CFrame.new(-0.3*i, 0.2*i, 0)
			end;
		};
		[2] = {
			duration = 3;
			maxIndex = 3;
			object = phoneModel.Case;
			cframe = function(i)
				return CFrame.new(-2.2*i, 0, 0)
			end;
		};
	}
	return tweenInfo
end

return Phone2 
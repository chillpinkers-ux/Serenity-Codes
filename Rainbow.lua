local Tween = game:GetService("TweenService")

local Settings = {
	Duration = 3
}

local Rainbow = {Tag = "Rainbow"}

Rainbow.__index = Rainbow

function Rainbow.new(Part : Instance) -- Has Instance : Instance
	local self = setmetatable({
		Part = Part
	}, Rainbow)
	
	self:_init()
	
	return self
end

function Rainbow:_init()
	local Part = self.Part
	
	local GeneralTween = TweenInfo.new(Settings.Duration)
	
	task.spawn(function()
		while true do
		
			local RandomR = math.random(1,255)
			local RandomG = math.random(1,255)
			local RandomB = math.random(1,255)
		
			local RandomColor = Color3.fromRGB(RandomR, RandomG, RandomB)
		
			local ColorTween = Tween:Create(Part, GeneralTween, {
				Color = RandomColor
			})
		
			ColorTween:Play()
			ColorTween.Completed:Wait()
		end
	end)
end

return Rainbow

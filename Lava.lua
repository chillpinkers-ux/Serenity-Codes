local Tween = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local ReplicatedStorage =  game:GetService("ReplicatedStorage")

local Events = ReplicatedStorage.Signal.Remote.Events

local AttackEV = Events.Attack

local SFX = script.SFX
local Particle = script.Particle

local Settings = {
	CooldownTime = 1,
	Damage = 20,
	LavaKillDuration = 0.25,
	EmitAmount = 10
}

local GeneralTween = TweenInfo.new(Settings.LavaKillDuration,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.Out,
	0,
	true
)


local Lava = {Tag = "Lava"}
Lava.__index = Lava

function Lava.new(Part : Instance) -- Has Instance : Instance
	local self = setmetatable({
		Lava = Part
	}, Lava)
	
	self:_init()
	
	return self
end

function Lava:_init()
	local Part : Part = self.Lava
	local OnCooldown = false
	
	Part.Touched:Connect(function(hit)
		if OnCooldown then return end
		OnCooldown = true
		task.spawn(function()
			local Humanoid = hit.Parent:FindFirstChild("Humanoid")
			if Humanoid then
				local LavaTween = Tween:Create(Part, GeneralTween, {Size = Part.Size * 0.9})
				LavaTween:Play()
				
				Humanoid:TakeDamage(Settings.Damage)
				
				local NewSFX = SFX:Clone()
				NewSFX.Parent = Part
				NewSFX:Play()
				
				local NewParticle = Particle:Clone()
				NewParticle.Parent = Part
				NewParticle:Emit(Settings.EmitAmount)
				
				NewSFX.Ended:Connect(function()
					NewSFX:Destroy()
				end)
				
				LavaTween.Completed:Connect(function()
					OnCooldown = false
				end)
				
				Debris:AddItem(NewParticle, NewParticle.Lifetime.Max)
			end
		end)
	end)
end

return Lava

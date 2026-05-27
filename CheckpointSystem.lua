local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local AnalyticsSerivce  = game:GetService("AnalyticsService")
local ServerScript = game:GetService("ServerScriptService")

local PlayerData = require(ServerScript.Utils.PlayerData)

local Events = ReplicatedStorage.Signal.Remote.Events
local Utils = ReplicatedStorage.Modules.Utils

local StatChecker = require(Utils.StatsChecker)

local Checkpoint_EV = Events.Checkpoint
local SkipStages = Events.SkipCheckpoint

local PREVENT_SKIPPING = false

local AddCoins = 5

local module = {}

function module.Start()
	local Checkpoints = CollectionService:GetTagged("Checkpoint")
	-- Sort the table Checkpoints by their Attributes "Stage".
	table.sort(Checkpoints, function(a, b)
		return a:GetAttribute("Stage") < b:GetAttribute("Stage")
	end)
	game.Players.PlayerAdded:connect(function(player : Player)
		local leaderstats = StatChecker:GetStat("leaderstats", player)
		local Hiddenstats = StatChecker:GetStat("Hiddenstats", player)
		local Coins = StatChecker:GetStat("Coins", leaderstats)
		local checkpointStat = StatChecker:GetStat("Stage", leaderstats)
		local CoinsMultiplier = StatChecker:GetStat("CoinMultiplier", Hiddenstats)
		
		local Loaded = false

		local function SpawnPlayer(character : Model)
			if not Loaded then return end
			local Humanoid : Humanoid = character:WaitForChild("Humanoid")
			local RootPart : Part = character:WaitForChild("HumanoidRootPart")
			local CurrentStage = checkpointStat.Value
			local Checkpoint : Model = Checkpoints[CurrentStage]
			local NextCheckpoint : Model = Checkpoints[CurrentStage + 1]

			player:RequestStreamAroundAsync(Checkpoint.Checkpoint.Position + Vector3.new(0,3,0))

			if not NextCheckpoint then
				RootPart.CFrame = Checkpoint.Checkpoint.CFrame + Vector3.new(0,3,0)
				return
			end

			RootPart.CFrame = Checkpoint.Checkpoint.CFrame + Vector3.new(0,3,0)
			RootPart.CFrame = CFrame.lookAt(Checkpoint.Checkpoint.Position, NextCheckpoint.Checkpoint.Position)
			
			local ForceField = character:FindFirstChildOfClass("ForceField")
			if ForceField then
				ForceField:Destroy()
			end
		end
		
		player.CharacterAdded:Once(function(character)
			if PlayerData.IsProfileLoaded(player) then
				local profile = PlayerData.GetData(player)
				Loaded = true
				SpawnPlayer(character)
				print(profile)
				task.wait(2)
				SkipStages:FireClient(player, profile.Stage)
			end
		end)
		
		player.CharacterAdded:connect(SpawnPlayer)
	end)


	Checkpoint_EV.OnServerEvent:Connect(function(player, Model : Model, CameraFromModel : Camera)
		local leaderstats = StatChecker:GetStat("leaderstats", player)
		local Hiddenstats = StatChecker:GetStat("Hiddenstats", player)
		local Coins = StatChecker:GetStat("Coins", leaderstats)
		local checkpointStat = StatChecker:GetStat("Stage", leaderstats)
		local CoinsMultiplier = StatChecker:GetStat("CoinMultiplier", Hiddenstats)
		local Index : number = Model:GetAttribute("Stage")

		local function Analyze()
			AnalyticsSerivce:LogEconomyEvent(player,
				Enum.AnalyticsEconomyFlowType.Source,
				"Coins",
				AddCoins * CoinsMultiplier.Value,
				Coins.Value + AddCoins * CoinsMultiplier.Value,
				Enum.AnalyticsEconomyTransactionType.Gameplay.Name
			)
		end

		local function LogStage(StepName : string, StepNumber : number)
			AnalyticsSerivce:LogOnboardingFunnelStepEvent(player, 
				StepNumber, 
				StepName
			)
		end

		local function LogAllStageFrom10()
			local Times = math.floor(checkpointStat.Value / 10)
			for i = 1, Times do
				LogStage("Stage " .. i * 10, i)
			end
		end

		local function UpStage()
			checkpointStat.Value = Index
			Coins.Value += AddCoins * CoinsMultiplier.Value
			Analyze()
			LogAllStageFrom10()
			SkipStages:FireClient(player, Index)
		end

		if PREVENT_SKIPPING and Index == checkpointStat.Value + 1 then
			UpStage()
		elseif not PREVENT_SKIPPING and Index > checkpointStat.Value then
			UpStage()
		end


	end)
end


return module

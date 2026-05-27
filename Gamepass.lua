local Marketplace = game:GetService("MarketplaceService")
local ReplicatedStorage=  game:GetService("ReplicatedStorage")

local Storage = ReplicatedStorage.Storage
local GamepassStorage = Storage.Items.Gamepass
local Data = ReplicatedStorage.Modules.Data

local GamepassData = require(Data.Gamepasses)
local SharedType = require(ReplicatedStorage.SharedType)

local module = {}

function module.Start()
	-- Gives player tools who bought a game from the GamepassStorage.
	local function GamepassAdded(plr, gamepassId)
		for i,v : SharedType.GamepassPacket in pairs(GamepassData) do
			if v.ID == gamepassId then
				if plr.Backpack:FindFirstChild(v.Name) == nil then
					local tool = v.Tool:Clone()
					tool.Parent = plr.Backpack
					end
				end
			end
		end
	-- Removes tools from player when gamepass is no longer owned.
	local function GamepassRemoved(plr, gamepassId)
		for i,v : Tool in pairs(plr.Backpack:GetChildren()) do
			if v:IsA("Tool") then
				if v:GetAttribute("GamepassID") == gamepassId then
					v:Destroy()
				end
			end
		end
		for i,v in pairs(plr.Character:GetChildren()) do
			if v:IsA("Tool") then
				if v:GetAttribute("GamepassID") == gamepassId then
					v:Destroy()
				end
			end
		end
	end
	-- Checks when player gains a gamepass.
	Marketplace.PromptGamePassPurchaseFinished:Connect(function(plr, gamepassId, wasPurchased)
		if wasPurchased then
			GamepassAdded(plr, gamepassId)
		end
	end)
	-- Checks if player owns gamepass when joining the game.
	game.Players.PlayerAdded:Connect(function(plr)
		plr.CharacterAdded:Connect(function()
		for i,gamepass : SharedType.GamepassPacket in pairs(GamepassData) do
				local owns = Marketplace:UserOwnsGamePassAsync(plr.UserId, gamepass.ID)
				if owns then
					GamepassAdded(plr, gamepass.ID)
				end
			end
		end)
	end)
end

return module

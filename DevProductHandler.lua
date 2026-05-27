MarketplaceService = game:GetService("MarketplaceService")

local module = {}

function module.Start()

	MarketplaceService.ProcessReceipt = function(receiptInfo)
		local players = game.Players:GetPlayers()

		local currency = "Stage"

		local done = 0 

		for i=1,#players do
			if players[i].UserId == receiptInfo.PlayerId then
				if receiptInfo.ProductId == 3292437016 and done == 0 then
					done = 1
					players[i].leaderstats[currency].Value = players[i].leaderstats[currency].Value + 1
					players[i].Character.Humanoid.Health = 0
					done = 0
				end
			end
		end
		
		for i=1,#players do
			if receiptInfo.ProductId == 3292437017 and done == 0 then
				done = 1

				players[i].Character.Humanoid.Health = 0
				done = 0
			end
		end
		
		
		return Enum.ProductPurchaseDecision.PurchaseGranted	
	end
end

return module

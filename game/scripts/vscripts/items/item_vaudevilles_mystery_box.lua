item_vaudevilles_mystery_box = class({})

function item_vaudevilles_mystery_box:IsConsumable()
	return true
end

function item_vaudevilles_mystery_box:OnSpellStart()
	if self:GetCaster():IsAlive() then
		local pID = self:GetCaster():GetPlayerID()
		local dropTable = {}
		local roll = RandomInt(1, 11)
		if roll < 3 then
			table.insert( dropTable, RelicManager:RollRandomUniqueRelicForPlayer(pID)	)
		elseif roll < 6 then
			table.insert( dropTable, RelicManager:RollRandomCursedRelicForPlayer(pID) )
		else
			table.insert( dropTable, RelicManager:RollRandomGenericRelicForPlayer(pID) )
		end
		
		RelicManager:PushCustomRelicDropsForPlayer(pID, dropTable)
		self:Destroy()
	end
end
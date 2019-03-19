relic_mimic_chest = class(relicBaseClass)
 
function relic_mimic_chest:OnCreated()
	if IsServer() then
		local relicTable = {}
	
		for relic, relicData in pairs(RelicManager.masterList) do
			table.insert( relicTable, relic )
		end
		if #relicTable >= 0 and self:GetParent():HasModifier("relic_ritual_candle") then
			local dropTable = {}
			table.insert( dropTable, relicTable[RandomInt(1,#relicTable)] )
			RelicManager:PushCustomRelicDropsForPlayer(self:GetParent():GetPlayerID(), dropTable)
		else
			self:GetParent():AddRelic( relicTable[RandomInt(1,#relicTable)] )
		end
		relicTable = nil
	end
end
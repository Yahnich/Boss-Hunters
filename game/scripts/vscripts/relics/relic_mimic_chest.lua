relic_mimic_chest = class(relicBaseClass)
 
function relic_mimic_chest:OnCreated()
	if IsServer() then
		local relicTable = {}
	
		for relic, relicData in pairs(RelicManager.masterList) do
			table.insert( relicTable, relic )
		end
		if #relicTable >= 0 and self:GetParent():HasModifier("relic_ritual_candle") then
			local relicData = {}
			relicData.name = relicTable[RandomInt(1,#relicTable)]
			relicData.rarity = RelicManager.masterList[relicData.name]["Rarity"]
			relicData.cursed = RelicManager.masterList[relicData.name]["Cursed"] == 1
			RelicManager:PushCustomRelicDropsForPlayer(self:GetParent():GetPlayerID(), {relicData})
		else
			self:GetParent():AddRelic( relicTable[RandomInt(1,#relicTable)] )
		end
		relicTable = nil
	end
end
relic_mimic_chest = class(relicBaseClass)
 
function relic_mimic_chest:OnCreated()
	if IsServer() then
		local relics = LoadKeyValues('scripts/npc/npc_relics_custom.txt')
		local relicTable = {}
	
		local roll = RandomInt(1,4)
		if roll == 1 then
			for relic, weight in pairs(relics.relic_type_cursed) do
				table.insert(relicTable, relic)
			end
		elseif roll == 2 then
			for relic, weight in pairs(relics.relic_type_unique) do
				table.insert(relicTable, relic)
			end
		else
			for relic, weight in pairs(relics.relic_type_generic) do
				table.insert(relicTable, relic)
			end
		end
		if self:GetParent():HasModifier("relic_ritual_candle") then
			local dropTable = {}
			table.insert( dropTable, relicTable[RandomInt(1,#relicTable)] )
			RelicManager:PushCustomRelicDropsForPlayer(self:GetParent():GetPlayerID(), dropTable)
		else
			self:GetParent():AddRelic( relicTable[RandomInt(1,#relicTable)] )
		end
		relicTable = nil
	end
end
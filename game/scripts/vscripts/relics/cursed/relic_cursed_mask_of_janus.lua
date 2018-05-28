relic_cursed_mask_of_janus = class(relicBaseClass)

if IsServer() then
	function relic_cursed_mask_of_janus:RerollRelic()
		local hero = self:GetParent()
		local pID = hero:GetPlayerID()
		if self:GetParent():HasModifier("relic_unique_ritual_candle") then return end
		local relicList = {}
		for item, relic in pairs( hero.ownedRelics ) do
			if relic ~= "relic_cursed_mask_of_janus" then
				table.insert(relicList, relic)
			end
		end
		local relic = relicList[RandomInt(1, #relicList)]
		RelicManager:RemoveRelicOnPlayer(relic, pID)
		local roll = RandomInt( 1, 3 )
		if roll == 1 then
			hero:AddRelic( RelicManager:RollRandomGenericRelicForPlayer(pID) )
		elseif roll == 2 then
			hero:AddRelic( RelicManager:RollRandomCursedRelicForPlayer(pID) )
		else
			hero:AddRelic( RelicManager:RollRandomUniqueRelicForPlayer(pID) )
		end
	end
end
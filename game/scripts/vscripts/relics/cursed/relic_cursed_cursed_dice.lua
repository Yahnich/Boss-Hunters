relic_cursed_cursed_dice = class(relicBaseClass)

function relic_cursed_cursed_dice:OnCreated()
	if IsServer() then
		local pID = self:GetParent():GetPlayerID()
		local rerolls = RelicManager:ClearRelics( pID )
		local bonusRolls = RandomInt(0, math.floor(rerolls/2) )
		for i = 1, rerolls + bonusRolls do
			local roll = RandomInt( 1, 3 )
			if roll == 1 then
				self:GetParent():AddRelic( RelicManager:RollRandomGenericRelicForPlayer(pID), "relic_cursed_cursed_dice" )
			elseif roll == 2 then
				self:GetParent():AddRelic( RelicManager:RollRandomCursedRelicForPlayer(pID), "relic_cursed_cursed_dice" )
			else
				self:GetParent():AddRelic( RelicManager:RollRandomUniqueRelicForPlayer(pID), "relic_cursed_cursed_dice" )
			end
		end
	end
end
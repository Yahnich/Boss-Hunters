relic_cursed_dice = class(relicBaseClass)

RELIC_RARITY_COMMON = 1

function relic_cursed_dice:OnCreated()
	if IsServer() and not self:GetAbility().diceHasBeenRolled then
		local pID = self:GetParent():GetPlayerID()
		if self:GetParent():HasModifier("relic_ritual_candle") then
			self:GetAbility().diceHasBeenRolled = true
			return
		end
		local rerolls = RelicManager:ClearRelics( pID )
		local bonusRolls = RandomInt(0, math.floor(rerolls/2) )
		for i = 1, rerolls + bonusRolls do
			self:GetParent():AddRelic( RelicManager:RollRandomRelicForPlayer(pID, "RARITY_COMMON", false, false, "relic_cursed_dice") )
		end
		self:GetAbility().diceHasBeenRolled = true
	end
end
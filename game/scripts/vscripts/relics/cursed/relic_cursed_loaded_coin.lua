relic_cursed_loaded_coin = class(relicBaseClass)

function relic_cursed_loaded_coin:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function relic_cursed_loaded_coin:GetModifierIncomingDamage_Percentage()
	if RollPercentage( 70 ) then
		return -100
	elseif not self:GetParent():HasModifier("relic_unique_ritual_candle") then 
		return 200 
	end
end
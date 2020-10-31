relic_loaded_coin = class(relicBaseClass)

function relic_loaded_coin:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function relic_loaded_coin:GetModifierIncomingDamage_Percentage()
	if RollPercentage( 60 ) then
		return -100
	elseif not self:GetParent():HasModifier("relic_ritual_candle") then 
		return 100 
	end
end
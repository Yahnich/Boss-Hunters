relic_glass_flower = class(relicBaseClass)

function relic_glass_flower:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function relic_glass_flower:GetModifierIncomingDamage_Percentage(params)
	if not self:GetParent():HasModifier("relic_ritual_candle") and not HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) then return 100 end
end

function relic_glass_flower:GetModifierTotalDamageOutgoing_Percentage(params)
	if params.target ~= self:GetParent() and not HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) then
		return 100
	end
end
relic_tortoise_greatshield = class(relicBaseClass)

function relic_tortoise_greatshield:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING}
end

function relic_tortoise_greatshield:GetModifierStatusAmplify_Percentage()
	if not self:GetParent():HasModifier("relic_ritual_candle") then return -35 end
end

function relic_tortoise_greatshield:GetModifierStatusResistanceStacking(params)
	return 50
end
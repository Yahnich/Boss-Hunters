relic_generic_leather_buckler = class(relicBaseClass)

function relic_generic_leather_buckler:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTAL_CONSTANT_BLOCK}
end

function relic_generic_leather_buckler:GetModifierTotal_ConstantBlock(params)
	if RollPercentage(60) and params.attacker ~= self:GetParent() and self:GetParent():IsRealHero() then
		return 20
	end
end
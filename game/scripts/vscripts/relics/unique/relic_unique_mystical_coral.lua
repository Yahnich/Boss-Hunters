relic_unique_mystical_coral = class(relicBaseClass)

function relic_unique_mystical_coral:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING}
end

function relic_unique_mystical_coral:GetModifierSpellAmplify_Percentage()
	if self:GetParent():InWater() then
		return 25
	end
end

function relic_unique_mystical_coral:GetModifierPercentageManacostStacking()
	if self:GetParent():InWater() then
		return 15
	end
end
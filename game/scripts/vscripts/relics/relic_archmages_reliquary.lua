relic_archmages_reliquary = class(relicBaseClass)

function relic_archmages_reliquary:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE }
end

function relic_archmages_reliquary:CheckState()
	return {[MODIFIER_STATE_DISARMED] = not self:GetParent():HasModifier("relic_ritual_candle")}
end

function relic_archmages_reliquary:GetModifierPhysicalArmorBonus()
	if not self:GetParent():HasModifier("relic_ritual_candle") then return -40 end
end

function relic_archmages_reliquary:GetModifierSpellAmplify_Percentage()
	return 75
end

function relic_archmages_reliquary:GetCooldownReduction()
	return 25
end


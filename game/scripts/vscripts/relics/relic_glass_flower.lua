relic_glass_flower = class(relicBaseClass)

function relic_glass_flower:DeclareFunctions()
	return {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, 
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function relic_glass_flower:GetModifierIncomingDamage_Percentage(params)
	if not self:GetParent():HasModifier("relic_ritual_candle") and not HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) then return 100 end
end

function relic_glass_flower:GetModifierDamageOutgoing_Percentage(params)
	return 75
end

function relic_glass_flower:GetModifierSpellAmplify_Percentage(params)
	return 75
end

function relic_glass_flower:GetModifierPhysicalArmorBonus(params)
	return -10
end

function relic_glass_flower:GetModifierMagicalResistanceBonus(params)
	return -50
end
relic_adamantium_ingot = class(relicBaseClass)

function relic_adamantium_ingot:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function relic_adamantium_ingot:GetModifierPhysicalArmorBonus()
	return 30
end

function relic_adamantium_ingot:GetModifierMagicalResistanceBonus()
	if not self:GetParent():HasModifier("relic_ritual_candle") then return -50 end
end


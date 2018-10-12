relic_unique_nautical_scale = class(relicBaseClass)

function relic_unique_nautical_scale:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_EVASION_CONSTANT }
end

function relic_unique_nautical_scale:GetModifierPhysicalArmorBonus()
	if self:GetParent():InWater() then
		return 8
	end
end

function relic_unique_nautical_scale:GetModifierMagicalResistanceBonus()
	if self:GetParent():InWater() then
		return 20
	end
end

function relic_unique_nautical_scale:GetModifierEvasion_Constant()
	if self:GetParent():InWater() then
		return 10
	end
end
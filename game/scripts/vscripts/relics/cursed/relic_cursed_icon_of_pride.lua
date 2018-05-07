relic_cursed_icon_of_pride = class({})

function relic_cursed_icon_of_pride:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_STATS_AGILITY_BONUS, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function relic_cursed_icon_of_pride:GetModifierBonusStats_Strength()
	return 40
end

function relic_cursed_icon_of_pride:GetModifierBonusStats_Agility()
	return 40
end

function relic_cursed_icon_of_pride:GetModifierBonusStats_Intellect()
	return 40
end

function relic_cursed_icon_of_pride:IsHidden()
	return true
end

function relic_cursed_icon_of_pride:IsPurgable()
	return false
end

function relic_cursed_icon_of_pride:RemoveOnDeath()
	return false
end

function relic_cursed_icon_of_pride:IsPermanent()
	return true
end

function relic_cursed_icon_of_pride:AllowIllusionDuplicate()
	return true
end

function relic_cursed_icon_of_pride:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
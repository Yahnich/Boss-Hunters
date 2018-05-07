relic_cursed_icon_of_greed = class({})

function relic_cursed_icon_of_greed:GetBonusGold()
	return 100
end

function relic_cursed_icon_of_greed:IsHidden()
	return true
end

function relic_cursed_icon_of_greed:IsPurgable()
	return false
end

function relic_cursed_icon_of_greed:RemoveOnDeath()
	return false
end

function relic_cursed_icon_of_greed:IsPermanent()
	return true
end

function relic_cursed_icon_of_greed:AllowIllusionDuplicate()
	return true
end

function relic_cursed_icon_of_greed:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
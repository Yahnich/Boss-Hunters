relic_cursed_battle_brew = class({})

function relic_cursed_battle_brew:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_MISS_PERCENTAGE}
end

function relic_cursed_battle_brew:Bonus_ThreatGain()
	return 50
end

function relic_cursed_battle_brew:GetModifierBonusStats_Strength()
	return 30
end

function relic_cursed_battle_brew:GetModifierAttackSpeedBonus_Constant()
	return 80
end

function relic_cursed_battle_brew:GetModifierMiss_Percentage()
	return 33
end

function relic_cursed_battle_brew:IsHidden()
	return true
end

function relic_cursed_battle_brew:IsPurgable()
	return false
end

function relic_cursed_battle_brew:RemoveOnDeath()
	return false
end

function relic_cursed_battle_brew:IsPermanent()
	return true
end

function relic_cursed_battle_brew:AllowIllusionDuplicate()
	return true
end

function relic_cursed_battle_brew:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
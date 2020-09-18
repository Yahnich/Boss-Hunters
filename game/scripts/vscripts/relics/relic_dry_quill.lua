relic_dry_quill = class(relicBaseClass)

function relic_dry_quill:DeclareFunctions()
	return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE }
end

function relic_dry_quill:GetModifierAttackSpeedBonus_Constant()
	return 12
end

function relic_dry_quill:GetModifierPercentageCooldown()
	return 8
end

function relic_dry_quill:GetModifierPreAttack_BonusDamage()
	return 12
end
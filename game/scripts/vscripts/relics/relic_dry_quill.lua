relic_dry_quill = class(relicBaseClass)

function relic_dry_quill:DeclareFunctions()
	return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function relic_dry_quill:GetModifierAttackSpeedBonus()
	return 15
end

function relic_dry_quill:GetCooldownReduction()
	return 8
end

function relic_dry_quill:GetModifierPreAttack_BonusDamage()
	return 12
end
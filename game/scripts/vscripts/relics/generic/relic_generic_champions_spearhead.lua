relic_generic_champions_spearhead = class(relicBaseClass)

function relic_generic_champions_spearhead:DeclareFunctions()
	return {MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS }
end

function relic_generic_champions_spearhead:GetModifierProjectileSpeedBonus()
	return 1000
end
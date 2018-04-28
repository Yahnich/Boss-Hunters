relic_generic_champions_spearhead = class({})

function relic_generic_champions_spearhead:DeclareFunctions()
	return {MODIFIER_PROPERTY_PROJECTILE_SPEED_BONUS }
end

function relic_generic_champions_spearhead:GetModifierProjectileSpeedBonus()
	return 1000
end

function relic_generic_champions_spearhead:IsHidden()
	return true
end

function relic_generic_champions_spearhead:IsPurgable()
	return false
end

function relic_generic_champions_spearhead:RemoveOnDeath()
	return false
end

function relic_generic_champions_spearhead:IsPermanent()
	return true
end

function relic_generic_champions_spearhead:AllowIllusionDuplicate()
	return true
end
relic_generic_katana = class({})

function relic_generic_katana:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end

function relic_generic_katana:GetModifierPreAttack_CriticalStrike()
	if RollPercentage(20) then return 150 end
end

function relic_generic_katana:IsHidden()
	return true
end

function relic_generic_katana:IsPurgable()
	return false
end

function relic_generic_katana:RemoveOnDeath()
	return false
end

function relic_generic_katana:IsPermanent()
	return true
end

function relic_generic_katana:AllowIllusionDuplicate()
	return true
end

function relic_generic_katana:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
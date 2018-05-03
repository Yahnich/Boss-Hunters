relic_cursed_bloody_silk = class({})

function relic_cursed_bloody_silk:IsHidden()
	return true
end

function relic_cursed_bloody_silk:IsPurgable()
	return false
end

function relic_cursed_bloody_silk:RemoveOnDeath()
	return false
end

function relic_cursed_bloody_silk:IsPermanent()
	return true
end

function relic_cursed_bloody_silk:AllowIllusionDuplicate()
	return true
end

function relic_cursed_bloody_silk:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
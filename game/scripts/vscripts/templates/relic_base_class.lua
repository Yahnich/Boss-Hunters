relicBaseClass = class({})

function relicBaseClass:IsHidden()
	return true
end

function relicBaseClass:DestroyOnExpire()
	return false
end

function relicBaseClass:IsPurgable()
	return false
end

function relicBaseClass:IsPurgeException()
	return false
end

function relicBaseClass:RemoveOnDeath()
	return false
end

function relicBaseClass:IsPermanent()
	return true
end

function relicBaseClass:AllowIllusionDuplicate()
	return false
end

function relicBaseClass:IsRelicModifier()
	return true
end

function relicBaseClass:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE
end
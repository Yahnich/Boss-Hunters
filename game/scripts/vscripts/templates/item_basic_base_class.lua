itemBasicBaseClass = class({})

function itemBasicBaseClass:IsHidden()
	return true
end

function itemBasicBaseClass:IsPurgable()
	return false
end

function itemBasicBaseClass:IsPurgeException()
	return false
end

function itemBasicBaseClass:RemoveOnDeath()
	return false
end

function itemBasicBaseClass:IsPassive()
	return true
end

function itemBasicBaseClass:AllowIllusionDuplicate()
	return true
end

function itemBasicBaseClass:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE
end
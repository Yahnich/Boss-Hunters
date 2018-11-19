itemBaseClass = class({})

function itemBaseClass:IsHidden()
	return true
end

function itemBaseClass:IsPurgable()
	return false
end

function itemBaseClass:IsPurgeException()
	return false
end

function itemBaseClass:RemoveOnDeath()
	return false
end

function itemBaseClass:IsPermanent()
	return true
end

function itemBaseClass:AllowIllusionDuplicate()
	return true
end

function itemBaseClass:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
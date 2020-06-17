talentBaseClass = class({})

function talentBaseClass:IsHidden()
	return true
end

function talentBaseClass:DestroyOnExpire()
	return false
end

function talentBaseClass:IsPurgable()
	return false
end

function talentBaseClass:IsPurgeException()
	return false
end

function talentBaseClass:RemoveOnDeath()
	return false
end

function talentBaseClass:IsPermanent()
	return true
end

function talentBaseClass:AllowIllusionDuplicate()
	return true
end

function talentBaseClass:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
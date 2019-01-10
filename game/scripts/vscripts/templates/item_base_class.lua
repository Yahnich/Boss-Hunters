itemBaseClass = class({})

function itemBaseClass:IsHidden()
	return true
end

function itemBaseClass:IsPurgable()
	return false
end

function itemBaseClass:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
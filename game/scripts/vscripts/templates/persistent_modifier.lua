persistentModifier = class({})

function persistentModifier:IsHidden()
	return true
end

function persistentModifier:IsPurgable()
	return false
end

function persistentModifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_MULTIPLE
end
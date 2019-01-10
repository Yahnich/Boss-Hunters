toggleModifierBaseClass = class({})

function toggleModifierBaseClass:IsPurgable()
	return false
end

function toggleModifierBaseClass:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
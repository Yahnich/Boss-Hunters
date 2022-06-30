itemAuraBaseClass = class(itemBasicBaseClass)

function itemAuraBaseClass:IsHidden()
	return false
end

function itemAuraBaseClass:IsPurgable()
	return false
end

function itemAuraBaseClass:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end
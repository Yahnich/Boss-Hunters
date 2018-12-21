modifier_type_wild_tag = class({})

function modifier_type_wild_tag:IsPurgable()
	return false
end

function modifier_type_wild_tag:IsHidden()
	return true
end
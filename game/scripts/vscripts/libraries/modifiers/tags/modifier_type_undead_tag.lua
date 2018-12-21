modifier_type_undead_tag = class({})

function modifier_type_undead_tag:IsPurgable()
	return false
end

function modifier_type_undead_tag:IsHidden()
	return true
end
modifier_perk_movement = class({})

function modifier_perk_movement:OnCreated( kv )
	self.move_cap = self:GetAbility():GetSpecialValueFor( "move_cap" )
end

function modifier_perk_movement:OnRefresh( kv )
	self.move_cap = self:GetAbility():GetSpecialValueFor( "move_cap" )
end

function modifier_perk_movement:IsHidden()
	return true
end

function modifier_perk_movement:GetModifierMoveSpeed_Max( params )
    if not self:GetParent():HasModifier("modifier_bloodseeker_thirst") then
		return self.move_cap
	else
		return 9999
	end
end

function modifier_perk_movement:GetModifierMoveSpeed_Limit( params )
	if not self:GetParent():HasModifier("modifier_bloodseeker_thirst") then
		return self.move_cap
	else
		return 9999
	end
end

function modifier_perk_movement:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_MAX,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
	}

	return funcs
end
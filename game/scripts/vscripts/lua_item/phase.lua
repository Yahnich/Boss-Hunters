LinkLuaModifier( "modifier_phase_boots_movespeed_cap", "lua_item/phase.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_phase_boots_movespeed_cap = class({})

function modifier_phase_boots_movespeed_cap:OnCreated( kv )
	self.move_cap = self:GetAbility():GetSpecialValueFor( "move_cap" )
end

function modifier_phase_boots_movespeed_cap:OnRefresh( kv )
	self.move_cap = self:GetAbility():GetSpecialValueFor( "move_cap" )
end

function modifier_phase_boots_movespeed_cap:IsHidden()
	return true
end

function modifier_phase_boots_movespeed_cap:GetModifierMoveSpeed_Max( params )
    if not self:GetParent():HasModifier("modifier_bloodseeker_thirst") then
		return self.move_cap
	else
		return 10000
	end
end

function modifier_phase_boots_movespeed_cap:GetModifierMoveSpeed_Limit( params )
	if not self:GetParent():HasModifier("modifier_bloodseeker_thirst") then
		return self.move_cap
	else
		return 10000
	end
end

function modifier_phase_boots_movespeed_cap:GetEffectName()
	return "particles/items2_fx/phase_boots.vpcf"
end

function modifier_phase_boots_movespeed_cap:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_MAX,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
	}

	return funcs
end

function ApplyPhase(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:AddNewModifier(caster, ability, "modifier_phase_boots_movespeed_cap", {duration = ability:GetDuration()})
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_phase_boots_boost", {duration = ability:GetDuration()})
end
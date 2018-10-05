boss_phantom_cold_touch = class({})

function boss_phantom_cold_touch:GetIntrinsicModifierName()
	return "modifier_boss_phantom_cold_touch"
end

modifier_boss_phantom_cold_touch = class({})
LinkLuaModifier("modifier_boss_phantom_cold_touch", "bosses/boss_phantom/boss_phantom_cold_touch", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_phantom_cold_touch:OnCreated()
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_boss_phantom_cold_touch:OnRefresh()
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_boss_phantom_cold_touch:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_boss_phantom_cold_touch:OnAttackLanded(params)
	if params.attacker == self:GetParent() and not params.attacker:PassivesDisabled() then
		if not params.target:FindModifierByNameAndCaster("modifier_boss_phantom_cold_touch_debuff", params.attacker) then
			params.target:AddNewModifier( params.attacker, self:GetAbility(), "modifier_boss_phantom_cold_touch_debuff", {duration = self.duration} )
		else
			params.target:FindModifierByNameAndCaster("modifier_boss_phantom_cold_touch_debuff", params.attacker):SetDuration( self.duration, true )
		end
	end
end

function modifier_boss_phantom_cold_touch:IsHidden()
	return false
end


modifier_boss_phantom_cold_touch_debuff = class({})
LinkLuaModifier("modifier_boss_phantom_cold_touch_debuff", "bosses/boss_phantom/boss_phantom_cold_touch", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_phantom_cold_touch_debuff:OnCreated()
	self.slow = self:GetSpecialValueFor("slow")
end

function modifier_boss_phantom_cold_touch_debuff:OnRefresh()
	self.slow = self:GetSpecialValueFor("slow")
end

function modifier_boss_phantom_cold_touch_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_boss_phantom_cold_touch_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_boss_phantom_cold_touch_debuff:GetEffectName()
	return "particles/units/heroes/hero_lich/lich_slowed_cold.vpcf"
end

function modifier_boss_phantom_cold_touch_debuff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
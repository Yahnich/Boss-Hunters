sylph_zephyr = sylph_zephyr or class({})

function sylph_zephyr:GetIntrinsicModifierName()
	return "modifier_sylph_zephyr_passive"
end

LinkLuaModifier( "modifier_sylph_zephyr_passive", "heroes/sylph/sylph_zephyr.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_sylph_zephyr_passive = modifier_sylph_zephyr_passive or class({})

function modifier_sylph_zephyr_passive:OnCreated()
	self.max = self:GetAbility():GetTalentSpecialValueFor("max_stacks")
	self.ms = self:GetAbility():GetTalentSpecialValueFor("ms_per_stack")
end

function modifier_sylph_zephyr_passive:IsPurgable()
	return false
end

function modifier_sylph_zephyr_passive:IsHidden()
	return false
end

function modifier_sylph_zephyr_passive:IsPassive()
	return true
end

function modifier_sylph_zephyr_passive:DeclareFunctions()
	funcs = {
				MODIFIER_EVENT_ON_ATTACK_START,
				MODIFIER_EVENT_ON_ATTACK_LANDED,
				MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
			}
	return funcs
end

function modifier_sylph_zephyr_passive:OnAttackStart(params)
	if self.currentTarget ~= params.target and params.attacker == self:GetParent() then
		self.currentTarget = params.target
		self:SetStackCount(0)
	end
end

function modifier_sylph_zephyr_passive:OnAttackLanded(params)
	if self.currentTarget == params.target and params.attacker == self:GetParent() and self:GetStackCount() < self.max then
		self:IncrementStackCount()
	end
end

function modifier_sylph_zephyr_passive:GetModifierMoveSpeedBonus_Constant()
	return self.ms * self:GetStackCount()
end


LinkLuaModifier( "modifier_sylph_zephyr_talent_1", "heroes/sylph/sylph_zephyr.lua", LUA_MODIFIER_MOTION_NONE )
modifier_sylph_zephyr_talent_1 = modifier_sylph_zephyr_talent_1 or class({})

function modifier_sylph_zephyr_talent_1:IsHidden()
	return true
end

function modifier_sylph_zephyr_talent_1:RemoveOnDeath()
	return false
end
bristleback_worked_up = class({})
LinkLuaModifier( "modifier_worked_up", "heroes/hero_bristleback/bristleback_worked_up.lua",LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_worked_up_stack", "heroes/hero_bristleback/bristleback_worked_up.lua",LUA_MODIFIER_MOTION_NONE )

function bristleback_worked_up:GetIntrinsicModifierName()
	return "modifier_worked_up"
end

modifier_worked_up = class({})
function modifier_worked_up:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}
	return funcs
end

function modifier_worked_up:OnAbilityExecuted(params)
	if IsServer() then
		if params.unit == self:GetCaster() and params.unit:HasAbility( params.ability:GetName() ) then
			params.unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_worked_up_stack", {Duration = self:GetSpecialValueFor("duration")})
		end
	end
end

function modifier_worked_up:IsHidden()
	return true
end

function modifier_worked_up:IsPurgable()
	return false
end

modifier_worked_up_stack = class({})
function modifier_worked_up_stack:OnCreated(kv)
	self:OnRefresh()
	if IsServer() then
		self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_bristleback/bristleback_warpath.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(self.nfx, 3, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.nfx, 4, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
		self:AddEffect(self.nfx)
	end
end

function modifier_worked_up_stack:OnRefresh(kv)
	self.dmg = self:GetSpecialValueFor("bonus_dmg")
	self.ms =  self:GetSpecialValueFor("bonus_ms")
	self.max =  self:GetSpecialValueFor("max_stacks")
	self.sa =  self:GetCaster():FindTalentValue("special_bonus_unique_bristleback_work_up_1")
	if IsServer() then self:AddIndependentStack(self:GetRemainingTime(), self.max) end
end

function modifier_worked_up_stack:OnStackCountChanged(iStacks)
	if IsServer() then
		self:GetCaster():CalculateStatBonus()
	end
end

function modifier_worked_up_stack:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}	
	return funcs
end

function modifier_worked_up_stack:GetModifierSpellAmplify_Percentage()
	return self.sa * self:GetStackCount()
end

function modifier_worked_up_stack:GetModifierMoveSpeedBonus_Percentage()
	return self.ms * self:GetStackCount()
end

function modifier_worked_up_stack:GetModifierPreAttack_BonusDamage()
	return self.dmg * self:GetStackCount()
end

function modifier_worked_up_stack:GetModifierModelScale()
	return self:GetStackCount()*3
end

function modifier_worked_up_stack:IsDebuff()
	return false
end

function modifier_worked_up_stack:GetEffectName()
	return "particles/units/heroes/hero_bristleback/bristleback_warpath_dust.vpcf"
end
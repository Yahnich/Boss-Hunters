sylph_aerodynamic = sylph_aerodynamic or class({})

function sylph_aerodynamic:OnSpellStart()
	EmitSoundOn("Ability.Powershot.Alt", self:GetCaster())
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_sylph_aerodynamic_buff", {duration = self:GetSpecialValueFor("duration")})
	local aeroFX = ParticleManager:CreateParticle("particles/heroes/sylph/sylph_aerodynamic_poof.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
	ParticleManager:ReleaseParticleIndex(aeroFX)
end

LinkLuaModifier( "modifier_sylph_aerodynamic_buff", "heroes/sylph/sylph_aerodynamic.lua", LUA_MODIFIER_MOTION_NONE )
modifier_sylph_aerodynamic_buff = modifier_sylph_aerodynamic_buff or class({})

function modifier_sylph_aerodynamic_buff:OnCreated()
	self.miss = self:GetAbility():GetSpecialValueFor("miss_chance")
	self.attackspeed = self:GetAbility():GetSpecialValueFor("attackspeed")
end

function modifier_sylph_aerodynamic_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MISS_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_sylph_aerodynamic_buff:OnAttackLanded(params)
	if params.attacker == self:GetCaster() and self:GetCaster():HasTalent("sylph_aerodynamic_talent_1") then
		params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_sylph_aerodynamic_debuff", {duration = 0.2})
	end
end


function modifier_sylph_aerodynamic_buff:GetModifierMiss_Percentage()
	return self.miss * (300/self:GetCaster():GetIdealSpeed())
end

function modifier_sylph_aerodynamic_buff:CheckState()
	local state = {[MODIFIER_STATE_CANNOT_MISS] = false}
	return state
end

function modifier_sylph_aerodynamic_buff:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end

function modifier_sylph_aerodynamic_buff:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

function modifier_sylph_aerodynamic_buff:GetEffectName()
	return "particles/heroes/sylph/sylph_aerodynamic.vpcf"
end

LinkLuaModifier( "modifier_sylph_aerodynamic_debuff", "heroes/sylph/sylph_aerodynamic.lua", LUA_MODIFIER_MOTION_NONE )
modifier_sylph_aerodynamic_debuff = class({})

function modifier_sylph_aerodynamic_debuff:OnCreated()
	self.slow = self:GetCaster():GetIdealSpeed()*(-1)
end

function modifier_sylph_aerodynamic_debuff:OnRefresh()
	self.slow = self:GetCaster():GetIdealSpeed()*(-1)
end

function modifier_sylph_aerodynamic_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
	}
	return funcs
end


function modifier_sylph_aerodynamic_debuff:GetModifierMoveSpeedBonus_Constant()
	return self.slow
end

function modifier_sylph_aerodynamic_debuff:GetModifierAttackSpeedBonus_Constant()
	return self.slow / 2
end

function modifier_sylph_aerodynamic_debuff:GetEffectName()
	return "particles/heroes/sylph/sylph_aerodynamic.vpcf"
end


LinkLuaModifier( "modifier_sylph_aerodynamic_talent_1", "heroes/sylph/sylph_aerodynamic.lua", LUA_MODIFIER_MOTION_NONE )
modifier_sylph_aerodynamic_talent_1 = modifier_sylph_aerodynamic_talent_1 or class({})

function modifier_sylph_aerodynamic_talent_1:IsHidden()
	return true
end

function modifier_sylph_aerodynamic_talent_1:RemoveOnDeath()
	return false
end
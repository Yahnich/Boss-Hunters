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
		params.target:ApplyLinearKnockback(150, 1, self:GetCaster())
	end
end


function modifier_sylph_aerodynamic_buff:GetModifierMiss_Percentage()
	return self.miss
end

function modifier_sylph_aerodynamic_buff:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

function modifier_sylph_aerodynamic_buff:GetEffectName()
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
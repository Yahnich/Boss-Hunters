oracle_fates = class({})
LinkLuaModifier("modifier_oracle_fates", "heroes/hero_oracle/oracle_fates", LUA_MODIFIER_MOTION_NONE)

function oracle_fates:IsStealable()
    return true
end

function oracle_fates:IsHiddenWhenStolen()
    return false
end

function oracle_fates:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local duration = self:GetTalentSpecialValueFor("duration")
	
	EmitSoundOn("Hero_Oracle.FatesEdict.Cast", caster)
	EmitSoundOn("Hero_Oracle.FatesEdict", target)

	ParticleManager:FireParticle("particles/units/heroes/hero_oracle/oracle_fatesedict_hit.vpcf", PATTACH_POINT_FOLLOW, caster, {[0]="attach_attack1"})

	target:AddNewModifier(caster, self, "modifier_oracle_fates", {Duration = duration})

	if caster:HasTalent("special_bonus_unique_oracle_fates_2") and target:GetTeam() ~= caster:GetTeam() then
		target:Daze(self, caster, duration)
	end

	self:StartDelayedCooldown(duration)
end

modifier_oracle_fates = class({})
function modifier_oracle_fates:OnCreated(table)
	self.mr = 100
	self.noMagic = 1
	self.slow_ms = -100

	if self:GetCaster():HasTalent("special_bonus_unique_oracle_fates_1") then
		self.mr = 50
		self.noMagic = 0
		self.slow_ms = -50
	end
end

function modifier_oracle_fates:OnRefresh(table)
	self.mr = 100
	self.noMagic = 1
	self.slow_ms = -100

	if self:GetCaster():HasTalent("special_bonus_unique_oracle_fates_1") then
		self.mr = 50
		self.noMagic = 0
		self.slow_ms = -50
	end
end

function modifier_oracle_fates:DeclareFunctions()
	local funcs = { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
					MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
					MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL}
	return funcs
end

function modifier_oracle_fates:GetModifierMagicalResistanceBonus()
	return self.mr
end

function modifier_oracle_fates:GetModifierMoveSpeedBonus_Percentage()
	return self.slow_ms
end

function modifier_oracle_fates:GetAbsoluteNoDamageMagical()
	return self.noMagic
end

function modifier_oracle_fates:OnRemoved()
	if IsServer() then
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_oracle_fates:GetEffectName()
	return "particles/units/heroes/hero_oracle/oracle_fatesedict.vpcf"
end

function modifier_oracle_fates:IsDebuff()
	return false
end

function modifier_oracle_fates:IsPurgable()
	return true
end
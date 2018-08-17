boss_aeon_fetal_syndrome = class({})

function boss_aeon_fetal_syndrome:OnAbilityPhaseStart()
	ParticleManager:FireTargetWarningParticle( self:GetCursorTarget() )
	return true
end

function boss_aeon_fetal_syndrome:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	target:AddNewModifier(caster, self, "modifier_boss_aeon_fetal_syndrome", {duration = self:GetSpecialValueFor("duration")})
end

modifier_boss_aeon_fetal_syndrome = class({})
LinkLuaModifier("modifier_boss_aeon_fetal_syndrome", "bosses/boss_aeon/boss_aeon_fetal_syndrome", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_aeon_fetal_syndrome:OnCreated()
	self.reduction = self:GetSpecialValueFor("dmg_reduction")
	self.loss = self.reduction / self:GetRemainingTime()
	self:StartIntervalThink(0.2)
end

function modifier_boss_aeon_fetal_syndrome:OnIntervalThink()
	self.reduction = self.reduction - self.loss
end
boss_aeon_chronal_sphere = class({})

function boss_aeon_chronal_sphere:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle( self:GetCursorPosition(), self:GetSpecialValueFor("max_radius") )
	return true
end

function boss_aeon_chronal_sphere:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	CreateModifierThinker(caster, self, "modifier_boss_aeon_chronal_sphere_thinker", {duration = self:GetSpecialValueFor("duration")}, position, caster:GetTeamNumber(), false)
end

modifier_boss_aeon_chronal_sphere_thinker = class({})
LinkLuaModifier("modifier_boss_aeon_chronal_sphere_thinker", "bosses/boss_aeon/boss_aeon_chronal_sphere", LUA_MODIFIER_MOTION_NONE)


function modifier_boss_aeon_chronal_sphere_thinker:OnCreated()
	self.max_radius = self:GetSpecialValueFor("max_radius")
	self.radius = 125
	self.growth = (self.max_radius - self.radius) / self:GetRemainingTime()
	if IsServer() then
		self.nFX = ParticleManager:CreateParticle("particles/units/bosses/boss_aeon/boss_aeon_chronal_sphere.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(self.nFX, 1, (Vector(self.radius, self.radius, self.radius)))
		self:GetParent():EmitSound("Hero_FacelessVoid.Chronosphere")
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_boss_aeon_chronal_sphere_thinker:OnIntervalThink()
	self.radius = self.radius + self.growth * FrameTime()
	ParticleManager:SetParticleControl(self.nFX, 1, (Vector(self.radius, self.radius, self.radius)))
end

function modifier_boss_aeon_chronal_sphere_thinker:OnDestroy()
	if IsServer() then
		ParticleManager:ClearParticle(self.nFX)
	end
end

function modifier_boss_aeon_chronal_sphere_thinker:IsAura()
	return true
end

function modifier_boss_aeon_chronal_sphere_thinker:GetModifierAura()
	return "modifier_boss_aeon_chronal_sphere_freeze"
end

function modifier_boss_aeon_chronal_sphere_thinker:GetAuraRadius()
	return self.radius
end

function modifier_boss_aeon_chronal_sphere_thinker:GetAuraDuration()
	return 0.5
end

function modifier_boss_aeon_chronal_sphere_thinker:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_boss_aeon_chronal_sphere_thinker:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_boss_aeon_chronal_sphere_thinker:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

modifier_boss_aeon_chronal_sphere_freeze = class({})
LinkLuaModifier("modifier_boss_aeon_chronal_sphere_freeze", "bosses/boss_aeon/boss_aeon_chronal_sphere", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_aeon_chronal_sphere_freeze:CheckState()
	return {[MODIFIER_STATE_FROZEN] = true,
			[MODIFIER_STATE_STUNNED] = true}
end

function modifier_boss_aeon_chronal_sphere_freeze:GetStatusEffectName()
	return "particles/status_fx/status_effect_faceless_chronosphere.vpcf"
end

function modifier_boss_aeon_chronal_sphere_freeze:StatusEffectPriority()
	return 10
end

function modifier_boss_aeon_chronal_sphere_freeze:IsPurgable()
	return true
end

function modifier_boss_aeon_chronal_sphere_freeze:IsStunDebuff()
	return true
end

function modifier_boss_aeon_chronal_sphere_freeze:IsPurgeException()
	return true
end
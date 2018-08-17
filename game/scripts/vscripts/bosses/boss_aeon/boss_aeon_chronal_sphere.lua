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
	self.max_radius = self:GetTalentSpecialValueFor("max_radius")
	self.radius = 125
	self.growth = (self.max_radius - self.radius) / self:GetRemainingTime()
	if IsServer() then
		-- self.nFX = ParticleManager:CreateParticle("particles/units/heroes/hero_alchemist/alchemist_acid_spray.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		-- ParticleManager:SetParticleControl(nFX, 0, (Vector(0, 0, 0)))
		-- ParticleManager:SetParticleControl(nFX, 1, (Vector(self.radius, 1, 1)))
		-- ParticleManager:SetParticleControl(nFX, 15, (Vector(25, 150, 25)))
		-- ParticleManager:SetParticleControl(nFX, 16, (Vector(0, 0, 0)))
		
		self:StartIntervalThink(0.01)
	end
end

function modifier_boss_aeon_chronal_sphere_thinker:OnIntervalThink()
	self.radius = self.radius + self.growth * FrameTime()
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
	return {[MODIFIER_STATE_FROZEN] = true}
end
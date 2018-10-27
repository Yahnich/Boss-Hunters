viper_nethertoxin_bh = class({})

function viper_nethertoxin_bh:OnSpellStart()
	local caster = self:GetCaster()
	local targetPos = self:GetCursorPosition()
	
	CreateModifierThinker(caster, self, "modifier_viper_nethertoxin_bh_thinker", {duration = self:GetTalentSpecialValueFor("duration")}, targetPos, caster:GetTeamNumber(), false)
end

modifier_viper_nethertoxin_bh_thinker = class({})
LinkLuaModifier("modifier_viper_nethertoxin_bh_thinker", "heroes/hero_viper/viper_nethertoxin_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_viper_nethertoxin_bh_thinker:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("radius")
	if IsServer() then
		EmitSoundOn("Hero_Alchemist.AcidSpray", self:GetParent())
		nFX = ParticleManager:CreateParticle("particles/units/heroes/hero_alchemist/alchemist_acid_spray.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl(nFX, 0, (Vector(0, 0, 0)))
		ParticleManager:SetParticleControl(nFX, 1, (Vector(self.radius, 1, 1)))
		ParticleManager:SetParticleControl(nFX, 15, (Vector(25, 150, 25)))
		ParticleManager:SetParticleControl(nFX, 16, (Vector(0, 0, 0)))
		self:AddEffect(nFX)
		
		self:GetAbility():StartDelayedCooldown()
	end
end

function modifier_viper_nethertoxin_bh_thinker:OnDestroy()
	if IsServer() then
		StopSoundOn("Hero_Alchemist.AcidSpray", self:GetParent())
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_viper_nethertoxin_bh_thinker:IsAura()
	return true
end

function modifier_viper_nethertoxin_bh_thinker:GetModifierAura()
	return "modifier_viper_nethertoxin_bh_debuff"
end

function modifier_viper_nethertoxin_bh_thinker:GetAuraRadius()
	return self.radius
end

function modifier_viper_nethertoxin_bh_thinker:GetAuraDuration()
	return 0.5
end

function modifier_viper_nethertoxin_bh_thinker:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_viper_nethertoxin_bh_thinker:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_viper_nethertoxin_bh_thinker:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

modifier_viper_nethertoxin_bh_debuff = class({})
LinkLuaModifier("modifier_viper_nethertoxin_bh_debuff", "heroes/hero_viper/viper_nethertoxin_bh", LUA_MODIFIER_MOTION_NONE )

function modifier_viper_nethertoxin_bh_debuff:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("damage")
	self.damage = self:GetTalentSpecialValueFor("damage")
end
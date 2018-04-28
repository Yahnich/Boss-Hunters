boss_aether_gravity_well = class({})

function boss_aether_gravity_well:GetIntrinsicModifierName()
	return "modifier_boss_aether_gravity_well"
end

modifier_boss_aether_gravity_well = class({})
LinkLuaModifier("modifier_boss_aether_gravity_well", "bosses/boss_aether/boss_aether_gravity_well", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_aether_gravity_well:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("aura_radius")
	if IsServer() then
		local auraFX = ParticleManager:CreateParticle("particles/bosses/boss_aether/boss_aether_gravity_well.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControl( auraFX, 1, Vector(self.radius, 1, 1) )
		self:AddEffect(auraFX)
	end
end

function modifier_boss_aether_gravity_well:CheckState()
	return {[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_boss_aether_gravity_well:IsAura()
	return true
end

function modifier_boss_aether_gravity_well:GetModifierAura()
	return "modifier_boss_aether_gravity_well_debuff"
end

function modifier_boss_aether_gravity_well:GetAuraRadius()
	return self.radius
end

function modifier_boss_aether_gravity_well:GetAuraDuration()
	return 0.2
end

function modifier_boss_aether_gravity_well:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_boss_aether_gravity_well:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_boss_aether_gravity_well:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_boss_aether_gravity_well:IsHidden()
	return true
end

modifier_boss_aether_gravity_well_debuff = class({})
LinkLuaModifier("modifier_boss_aether_gravity_well_debuff", "bosses/boss_aether/boss_aether_gravity_well", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_boss_aether_gravity_well_debuff:OnCreated()
		self.max_dmg = self:GetTalentSpecialValueFor("max_damage")
		self.max_pull = self:GetTalentSpecialValueFor("max_pull")
		self.radius = self:GetTalentSpecialValueFor("aura_radius")
		self:StartIntervalThink( 0.25 )
	end
	
	function modifier_boss_aether_gravity_well_debuff:OnIntervalThink()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		if not caster or caster:IsNull() then self:Destroy() end
		local direction = CalculateDirection( caster, parent )
		local distance = CalculateDistance( caster, parent )
		
		local strength = (self.radius - distance) / self.radius

		local tickDamage = (parent:GetMaxHealth() * strength * self.max_dmg / 100 ) * 0.25
		self:GetAbility():DealDamage( caster, parent, tickDamage, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
	end
end
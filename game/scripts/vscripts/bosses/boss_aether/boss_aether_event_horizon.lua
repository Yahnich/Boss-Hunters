boss_aether_event_horizon = class({})

function boss_aether_event_horizon:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle(self:GetCaster():GetAbsOrigin(), self:GetTalentSpecialValueFor("radius") )
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_status_immunity", {duration = self:GetCastPoint() - 0.01})
	return true
end

function boss_aether_event_horizon:OnSpellStart()
	local caster = self:GetCaster()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_status_immunity", {duration = self:GetCastPoint() - 0.01})
	if self.dummy then boss_aether_event_horizon:OnChannelFinish(true) end
	self.dummy = CreateModifierThinker(self:GetCaster(), self, "modifier_boss_aether_event_horizon_aura", {duration = self:GetChannelTime()}, caster:GetAbsOrigin(), self:GetCaster():GetTeam(), false)
end

function boss_aether_event_horizon:OnChannelFinish(bInterrupt)
	UTIL_Remove(self.dummy)
end


modifier_boss_aether_event_horizon_aura = class({})
LinkLuaModifier("modifier_boss_aether_event_horizon_aura", "bosses/boss_aether/boss_aether_event_horizon", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_aether_event_horizon_aura:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("radius")
	self.pull = self:GetTalentSpecialValueFor("pull")
	if IsServer() then
		self.aFX = ParticleManager:CreateParticle("particles/units/heroes/hero_enigma/enigma_blackhole.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		self:StartIntervalThink( FrameTime() )
	end
end

function modifier_boss_aether_event_horizon_aura:OnIntervalThink()
	if IsServer() then
		local caster = self:GetCaster()
		if not caster or caster:IsNull() then self:Destroy() end
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), -1 ) ) do
			enemy:SetAbsOrigin( GetGroundPosition(enemy:GetAbsOrigin() + CalculateDirection( caster, enemy ) * self.pull, enemy) )
			self:GetAbility():DealDamage( caster, parent, tickDamage, {damage_type = DAMAGE_TYPE_PURE, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
		end
		ResolveNPCPositions(caster:GetAbsOrigin(), 9000)
	end
end

function modifier_boss_aether_event_horizon_aura:OnDestroy()
	if IsServer() then 
		ParticleManager:ClearParticle( self.aFX )
		UTIL_Remove( self:GetParent() )
	end
end

function modifier_boss_aether_event_horizon_aura:IsAura()
	return true
end

function modifier_boss_aether_event_horizon_aura:GetModifierAura()
	return "modifier_boss_aether_event_horizon_debuff"
end

function modifier_boss_aether_event_horizon_aura:GetAuraRadius()
	return self.radius
end

function modifier_boss_aether_event_horizon_aura:GetAuraDuration()
	return 0.5
end

function modifier_boss_aether_event_horizon_aura:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_boss_aether_event_horizon_aura:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_boss_aether_event_horizon_aura:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

modifier_boss_aether_event_horizon_debuff = class({})
LinkLuaModifier("modifier_boss_aether_event_horizon_debuff", "bosses/boss_aether/boss_aether_event_horizon", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_aether_event_horizon_debuff:OnCreated()
	self.damage = (self:GetTalentSpecialValueFor("damage_per_second") * 0.25) / 100
	if IsServer() then
		self:StartIntervalThink(0.25)
	end
end

function modifier_boss_aether_event_horizon_debuff:OnIntervalThink()
	if IsServer() then
		local parent = self:GetParent()
		local caster = self:GetCaster()
	end
end
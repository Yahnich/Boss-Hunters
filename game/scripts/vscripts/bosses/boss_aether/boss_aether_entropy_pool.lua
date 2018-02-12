boss_aether_entropy_pool = class({})

function boss_aether_entropy_pool:OnAbilityPhaseStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_status_immunity", {duration = self:GetCastPoint() - 0.01})
	return true
end

function boss_aether_entropy_pool:OnSpellStart()
	self.channelThink = 0
	self.channelDuration = 0
	self.channelDelay = self:GetTalentSpecialValueFor("pool_creation_time")
	self.poolTable = {}
	EmitSoundOn("Hero_Enigma.Midnight_Pulse", self:GetCaster() )
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_status_immunity", {duration = self:GetChannelTime() - 0.01})
end

function boss_aether_entropy_pool:OnChannelThink(dt)
	self.channelThink = self.channelThink + dt
	self.channelDuration = self.channelDuration + dt
	if self.channelThink > self.channelDelay then
		local caster = self:GetCaster()
		self.channelThink = 0
		local range = self:GetTalentSpecialValueFor("pool_spawn_range")
		local maxRadius = self:GetTalentSpecialValueFor("initial_radius") + self:GetChannelTime() * self:GetTalentSpecialValueFor("radius_growth") / FrameTime()
		local position = caster:GetAbsOrigin() + ActualRandomVector(range, maxRadius / 2)
		table.insert( self.poolTable, self:CreateEntropyPool(GetGroundPosition( position, caster), duration) )
	end
end

function boss_aether_entropy_pool:OnChannelFinish(bInterrupted)
	for _, dummy in ipairs(self.poolTable) do
		dummy:FindModifierByName("modifier_boss_aether_entropy_pool_aura"):SetDuration(5, true)
	end
	StopSoundOn("Hero_Enigma.Midnight_Pulse", self:GetCaster() )
end

function boss_aether_entropy_pool:CreateEntropyPool(position, duration)
	return CreateModifierThinker(self:GetCaster(), self, "modifier_boss_aether_entropy_pool_aura", {}, position, self:GetCaster():GetTeam(), false)
end

modifier_boss_aether_entropy_pool_aura = class({})
LinkLuaModifier("modifier_boss_aether_entropy_pool_aura", "bosses/boss_aether/boss_aether_entropy_pool", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_aether_entropy_pool_aura:OnCreated()
	self.radius = self:GetTalentSpecialValueFor("initial_radius")
	self.rGrowth = self:GetTalentSpecialValueFor("radius_growth")
	if IsServer() then
		self.aFX = ParticleManager:CreateParticle("particles/bosses/boss_aether/boss_aether_entropy_pool.vpcf", PATTACH_POINT_FOLLOW, self:GetParent() )
		self:StartIntervalThink( FrameTime() )
	end
end

function modifier_boss_aether_entropy_pool_aura:OnIntervalThink()
	self.radius = self.radius + self.rGrowth
	if IsServer() then
		ParticleManager:SetParticleControl( self.aFX, 1, Vector(self.radius, 1, 1) )
	end
end

function modifier_boss_aether_entropy_pool_aura:OnDestroy()
	if IsServer() then 
		ParticleManager:ClearParticle( self.aFX )
		UTIL_Remove( self:GetParent() )
	end
end

function modifier_boss_aether_entropy_pool_aura:IsAura()
	return true
end

function modifier_boss_aether_entropy_pool_aura:GetModifierAura()
	return "modifier_boss_aether_entropy_pool_debuff"
end

function modifier_boss_aether_entropy_pool_aura:GetAuraRadius()
	return self.radius
end

function modifier_boss_aether_entropy_pool_aura:GetAuraDuration()
	return 0.2
end

function modifier_boss_aether_entropy_pool_aura:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_boss_aether_entropy_pool_aura:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_boss_aether_entropy_pool_aura:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

modifier_boss_aether_entropy_pool_debuff = class({})
LinkLuaModifier("modifier_boss_aether_entropy_pool_debuff", "bosses/boss_aether/boss_aether_entropy_pool", LUA_MODIFIER_MOTION_NONE)

function modifier_boss_aether_entropy_pool_debuff:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("damage_per_second") * 0.25
	if IsServer() then
		self:StartIntervalThink(0.25)
	end
end

function modifier_boss_aether_entropy_pool_debuff:OnIntervalThink()
	if IsServer() then
		self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.damage )
	end
end
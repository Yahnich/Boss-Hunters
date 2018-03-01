shadow_shaman_binding_shackle = class({})

function shadow_shaman_binding_shackle:GetChannelTime()
	self.duration = self:GetTalentSpecialValueFor( "channel_time" )

	if IsServer() then
		if self.shackleTarget ~= nil then
			return self.duration
		end

		return 0.0
	end

	return self.duration
end

function shadow_shaman_binding_shackle:OnSpellStart()
	local hTarget = self:GetCursorTarget()
	local hCaster = self:GetCaster()
	self.shackleTarget = hTarget
	
	-- cosmetic
	EmitSoundOn("Hero_ShadowShaman.Shackles.Cast", hCaster)

	
	if hTarget:IsIllusion() then
		hTarget:ForceKill(true)
	else
		hTarget:AddNewModifier(hCaster, self, "modifier_shadow_shaman_bound_shackles", {duration = self:GetTalentSpecialValueFor("channel_time")})
	end
end


LinkLuaModifier("modifier_shadow_shaman_bound_shackles", "heroes/hero_shadow_shaman/shadow_shaman_binding_shackle", LUA_MODIFIER_MOTION_NONE)
modifier_shadow_shaman_bound_shackles = class({})

function modifier_shadow_shaman_bound_shackles:OnCreated()
	self.duration = self:GetRemainingTime()
	self.damage = self:GetAbility():GetTalentSpecialValueFor("total_damage")
	self.tick = self:GetAbility():GetTalentSpecialValueFor("tick_interval")
	EmitSoundOn("Hero_ShadowShaman.Shackles", self:GetParent())
	if IsServer() then
		self:StartIntervalThink(self.tick)
		self:GetAbility():StartDelayedCooldown()
	end
	local shackles = ParticleManager:CreateParticle("particles/units/heroes/hero_shadowshaman/shadowshaman_shackle.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(shackles, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(shackles, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(shackles, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(shackles, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	
	ParticleManager:SetParticleControlEnt(shackles, 5, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(shackles, 6, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetCaster():GetAbsOrigin(), true)
	
	self:AddParticle(shackles, false, false, 10, false, false)
end

function modifier_shadow_shaman_bound_shackles:OnRefresh()
	self.duration = self:GetRemainingTime()
	self.damage = self:GetAbility():GetTalentSpecialValueFor("total_damage")
	self.tick = self:GetAbility():GetTalentSpecialValueFor("tick_interval")
	EmitSoundOn("Hero_ShadowShaman.Shackles", self:GetParent())
	if IsServer() then
		self:GetAbility():StartDelayedCooldown()
	end
end

function modifier_shadow_shaman_bound_shackles:OnIntervalThink()
	if not self:GetCaster():IsChanneling() then self:Destroy() end
	ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), damage = (self.damage/self.duration)*self.tick, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
end

function modifier_shadow_shaman_bound_shackles:OnDestroy()
	StopSoundOn("Hero_ShadowShaman.Shackles", self:GetParent())
	if IsServer() then
		self:GetCaster():InterruptChannel()
		self:GetAbility():EndDelayedCooldown()
		self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_shadow_shaman_bound_shackles_post", {duration = self:GetAbility():GetTalentSpecialValueFor("aftershackle_duration")})
	end
end

function modifier_shadow_shaman_bound_shackles:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}

	return funcs
end

function modifier_shadow_shaman_bound_shackles:GetOverrideAnimation()
	return ACT_DOTA_DISABLED
end

function modifier_shadow_shaman_bound_shackles:GetStatusEffectName()
	return "particles/status_fx/status_effect_shaman_shackle.vpcf"
end

function modifier_shadow_shaman_bound_shackles:StatusEffectPriority()
	return 10
end


function modifier_shadow_shaman_bound_shackles:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

LinkLuaModifier("modifier_shadow_shaman_bound_shackles_post", "heroes/hero_shadow_shaman/shadow_shaman_binding_shackle", LUA_MODIFIER_MOTION_NONE)
modifier_shadow_shaman_bound_shackles_post = class({})

function modifier_shadow_shaman_bound_shackles_post:OnCreated()
	self.duration = self:GetRemainingTime()
	self.damage = self:GetAbility():GetTalentSpecialValueFor("total_damage")
	self.tick = self:GetAbility():GetTalentSpecialValueFor("tick_interval")
	EmitSoundOn("Hero_ShadowShaman.Shackles", self:GetParent())
	if IsServer() then
		self:StartIntervalThink(self.tick)
	end
	local shackles = ParticleManager:CreateParticle("particles/units/heroes/hero_shadowshaman/shadowshaman_shackle.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt(shackles, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(shackles, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(shackles, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(shackles, 4, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	
	ParticleManager:SetParticleControlEnt(shackles, 5, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(shackles, 6, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_attack2", self:GetParent():GetAbsOrigin(), true)
	
	self:AddParticle(shackles, false, false, 10, false, false)
end

function modifier_shadow_shaman_bound_shackles_post:OnIntervalThink()
	ApplyDamage({ victim = self:GetParent(), attacker = self:GetCaster(), damage = (self.damage/self.duration)*self.tick, damage_type = self:GetAbility():GetAbilityDamageType(), ability = self:GetAbility()})
end

function modifier_shadow_shaman_bound_shackles_post:OnDestroy()
	StopSoundOn("Hero_ShadowShaman.Shackles", self:GetParent())
end

function modifier_shadow_shaman_bound_shackles_post:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}

	return funcs
end

function modifier_shadow_shaman_bound_shackles_post:GetOverrideAnimation()
	return ACT_DOTA_DISABLED
end

function modifier_shadow_shaman_bound_shackles_post:GetStatusEffectName()
	return "particles/status_fx/status_effect_shaman_shackle.vpcf"
end

function modifier_shadow_shaman_bound_shackles_post:StatusEffectPriority()
	return 10
end


function modifier_shadow_shaman_bound_shackles_post:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end
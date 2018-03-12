brewmaster_primal_avatar = class({})

function brewmaster_primal_avatar:IsStealable()
	return true
end

function brewmaster_primal_avatar:IsHiddenWhenStolen()
	return false
end

function brewmaster_primal_avatar:OnSpellStart()
	local caster = self:GetCaster()
	
	EmitSoundOn("Hero_Brewmaster.PrimalSplit.Cast", caster)
	caster:AddNewModifier(caster, self, "modifier_brewmaster_primal_avatar", {duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_brewmaster_primal_avatar = class({})
LinkLuaModifier("modifier_brewmaster_primal_avatar", "heroes/hero_brewmaster/brewmaster_primal_avatar", LUA_MODIFIER_MOTION_NONE)

function modifier_brewmaster_primal_avatar:OnCreated()
	self.damage_reduction = self:GetTalentSpecialValueFor("damage_reduction")
	self.radius = self:GetTalentSpecialValueFor("aoe_radius")
	if IsServer() then
		local eFX = ParticleManager:CreateParticle("particles/econ/items/sven/sven_warcry_ti5/sven_warcry_ti5_ambient_arcs.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		self:AddEffect(eFX)
		local wFX = ParticleManager:CreateParticle("particles/units/heroes/hero_windrunner/windrunner_windrun_whirlwind.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		self:AddEffect(wFX)
		local sFX = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/earthspirit_petrify_debuff_stoned.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		self:AddEffect(sFX)
		local fFX = ParticleManager:CreateParticle("particles/units/heroes/hero_brewmaster/brewmaster_fire_immolation_child.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		self:AddEffect(fFX)
		
		self:GetAbility():StartDelayedCooldown() 
	end
end
 
function modifier_brewmaster_primal_avatar:OnRefresh()
	self.damage_reduction = self:GetTalentSpecialValueFor("damage_reduction")
	self.radius = self:GetTalentSpecialValueFor("aoe_radius")
	if IsServer() then self:GetAbility():StartDelayedCooldown() end
end

function modifier_brewmaster_primal_avatar:OnDestroy()
	if IsServer() then self:GetAbility():EndDelayedCooldown() end
end

function modifier_brewmaster_primal_avatar:CheckState()
	return {[MODIFIER_STATE_MAGIC_IMMUNE] = true}
end

function modifier_brewmaster_primal_avatar:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN, 
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			MODIFIER_PROPERTY_MODEL_SCALE}
end

function modifier_brewmaster_primal_avatar:GetModifierMoveSpeed_AbsoluteMin(params)
	return 550
end

function modifier_brewmaster_primal_avatar:GetModifierIncomingDamage_Percentage(params)
	return self.damage_reduction
end

function modifier_brewmaster_primal_avatar:GetModifierModelScale(params)
	return 50
end

function modifier_brewmaster_primal_avatar:IsAura()
	return true
end

function modifier_brewmaster_primal_avatar:GetModifierAura()
	return "modifier_brewmaster_primal_avatar_debuff"
end

function modifier_brewmaster_primal_avatar:GetAuraRadius()
	return self.radius
end

function modifier_brewmaster_primal_avatar:GetAuraDuration()
	return 0.5
end

function modifier_brewmaster_primal_avatar:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_brewmaster_primal_avatar:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_brewmaster_primal_avatar:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_brewmaster_primal_avatar:GetStatusEffectName()
	return "particles/status_fx/status_effect_electrical.vpcf"
end

function modifier_brewmaster_primal_avatar:StatusEffectPriority()
	return 10
end

modifier_brewmaster_primal_avatar_debuff = class({})
LinkLuaModifier("modifier_brewmaster_primal_avatar_debuff", "heroes/hero_brewmaster/brewmaster_primal_avatar", 0)

function modifier_brewmaster_primal_avatar_debuff:OnCreated()
	self.miss = self:GetTalentSpecialValueFor("aoe_blind")
	self.tick = self:GetTalentSpecialValueFor("tick_interval")
	self.damage = self:GetTalentSpecialValueFor("aoe_damage_tooltip") * self.tick
	if IsServer() then self:StartIntervalThink(self.tick) end
end

function modifier_brewmaster_primal_avatar_debuff:OnRefresh()
	self.miss = self:GetTalentSpecialValueFor("aoe_blind")
	self.tick = self:GetTalentSpecialValueFor("tick_interval")
	self.damage = self:GetTalentSpecialValueFor("aoe_damage_tooltip") * self.tick
end

function modifier_brewmaster_primal_avatar_debuff:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage)
end

function modifier_brewmaster_primal_avatar_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MISS_PERCENTAGE}
end

function modifier_brewmaster_primal_avatar_debuff:GetModifierMiss_Percentage(params)
	return self.miss
end

function modifier_brewmaster_primal_avatar_debuff:GetEffectName()
	return "particles/units/heroes/hero_brewmaster/brewmaster_fire_immolation_child.vpcf"
end
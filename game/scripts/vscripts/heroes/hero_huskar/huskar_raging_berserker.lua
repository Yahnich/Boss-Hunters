huskar_raging_berserker = class({})

function huskar_raging_berserker:IsStealable()
	return true
end

function huskar_raging_berserker:OnUpgrade()
	local caster = self:GetCaster()
	
	caster:RemoveModifierByName("modifier_huskar_raging_berserker_passive")
	caster:AddNewModifier( caster, self, "modifier_huskar_raging_berserker_passive", {} )
	
	for _, ally in ipairs( caster:FindFriendlyUnitsInRadius( caster:GetAbsOrigin(), self:GetCaster():FindTalentValue("special_bonus_unique_huskar_raging_berserker_2") + 25 ) ) do
		ally:RemoveModifierByName("modifier_huskar_raging_berserker_effect")
	end
end

function huskar_raging_berserker:IsHiddenWhenStolen()
	return false
end

function huskar_raging_berserker:GetBehavior()
	if self:GetCaster():HasTalent("special_bonus_unique_huskar_raging_berserker_1") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
	end
	return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function huskar_raging_berserker:GetCooldown(iLvl)
	return self:GetCaster():FindTalentValue("special_bonus_unique_huskar_raging_berserker_1")
end

function huskar_raging_berserker:GetIntrinsicModifierName()
	return "modifier_huskar_raging_berserker_passive"
end

function huskar_raging_berserker:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_huskar_raging_berserker_active", {duration = self:GetCaster():FindTalentValue("special_bonus_unique_huskar_raging_berserker_1", "duration")})
end

modifier_huskar_raging_berserker_active = class({})
LinkLuaModifier("modifier_huskar_raging_berserker_active", "heroes/hero_huskar/huskar_raging_berserker", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_huskar_raging_berserker_active:OnCreated()
		self:GetAbility():StartDelayedCooldown()
	end
	
	function modifier_huskar_raging_berserker_active:OnRefresh()
		self:GetAbility():StartDelayedCooldown()
	end
	
	function modifier_huskar_raging_berserker_active:OnDestroy()
		self:GetAbility():EndDelayedCooldown()
	end
end

modifier_huskar_raging_berserker_passive = class({})
LinkLuaModifier("modifier_huskar_raging_berserker_passive", "heroes/hero_huskar/huskar_raging_berserker", LUA_MODIFIER_MOTION_NONE)

function modifier_huskar_raging_berserker_passive:OnCreated()
	self.radius = self:GetCaster():FindTalentValue("special_bonus_unique_huskar_raging_berserker_2")
end

function modifier_huskar_raging_berserker_passive:OnRefresh()
	self.radius = self:GetCaster():FindTalentValue("special_bonus_unique_huskar_raging_berserker_2")
end

function modifier_huskar_raging_berserker_passive:IsAura()
	return true
end

function modifier_huskar_raging_berserker_passive:GetModifierAura()
	return "modifier_huskar_raging_berserker_effect"
end

function modifier_huskar_raging_berserker_passive:GetAuraRadius()
	return self.radius
end

function modifier_huskar_raging_berserker_passive:GetAuraDuration()
	return 0.5
end

function modifier_huskar_raging_berserker_passive:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_huskar_raging_berserker_passive:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_HERO
end

function modifier_huskar_raging_berserker_passive:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_huskar_raging_berserker_passive:IsHidden()
	return true
end

function modifier_huskar_raging_berserker_passive:IsPurgable()
	return false
end

modifier_huskar_raging_berserker_effect = class({})
LinkLuaModifier("modifier_huskar_raging_berserker_effect", "heroes/hero_huskar/huskar_raging_berserker", LUA_MODIFIER_MOTION_NONE)

function modifier_huskar_raging_berserker_effect:OnCreated()
	self:OnRefresh()
	self:StartIntervalThink(0.3)
	if IsServer() then
		self.glowFX = ParticleManager:CreateParticle("particles/units/heroes/hero_huskar/huskar_berserkers_blood_glow.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	end
end

function modifier_huskar_raging_berserker_effect:OnRefresh()
	self.as = self:GetTalentSpecialValueFor("maximum_as")
	-- self.mr = self:GetTalentSpecialValueFor("maximum_resistance")
	self.regen = self:GetParent():GetStrength() * self:GetTalentSpecialValueFor("maximum_regen") / 100
	self.hpThreshold = self:GetTalentSpecialValueFor("hp_threshold_max")
	self.hpPct = math.min(1, (100 - self:GetParent():GetHealthPercent()) / (100 - self.hpThreshold) )
end

function modifier_huskar_raging_berserker_effect:OnDestroy()
	if IsServer() then ParticleManager:ClearParticle( self.glowFX ) end
end

function modifier_huskar_raging_berserker_effect:OnIntervalThink()
	self.hpPct = math.min(1, (100 - self:GetParent():GetHealthPercent()) / (100 - self.hpThreshold) )
	if self:GetCaster():HasModifier("modifier_huskar_raging_berserker_active") then
		self.hpPct = 1
	end
	if IsServer() then
		ParticleManager:SetParticleControl(self.glowFX, 1, Vector(self.hpPct * 100, 0, 0) )
	end
	self.regen = self:GetParent():GetStrength() * self:GetTalentSpecialValueFor("maximum_regen") / 100
	self.total_as = self.as * self.hpPct 
	-- self.total_mr = self.mr * self.hpPct 
	self.total_regen = self.regen * self.hpPct
	
	self.rTalent1 = self:GetCaster():FindTalentValue("special_bonus_unique_huskar_sunder_life_1")
	if self:GetCaster():HasModifier("modifier_huskar_sunder_life_talent") then
		self.total_as = self.total_as * self.rTalent1
		-- self.total_mr = math.min( self.total_mr * self.rTalent1, 99 )
		self.total_regen = self.total_regen * self.rTalent1
	end
end

function modifier_huskar_raging_berserker_effect:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, 
			-- MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, 
			MODIFIER_PROPERTY_MODEL_SCALE, 
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT }
end

function modifier_huskar_raging_berserker_effect:GetModifierAttackSpeedBonus_Constant()
	return self.total_as
end

function modifier_huskar_raging_berserker_effect:GetModifierConstantHealthRegen()
	return self.total_regen
end

-- function modifier_huskar_raging_berserker_effect:GetModifierMagicalResistanceBonus()
	-- return self.total_mr
-- end

function modifier_huskar_raging_berserker_effect:GetModifierModelScale()
	return 35 * self.hpPct
end

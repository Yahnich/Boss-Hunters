huskar_raging_berserker = class({})

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

function modifier_huskar_raging_berserker_passive:IsAura()
	return true
end

function modifier_huskar_raging_berserker_passive:GetModifierAura()
	return "modifier_huskar_raging_berserker_effect"
end

function modifier_huskar_raging_berserker_passive:GetAuraRadius()
	return self:GetCaster():FindTalentValue("special_bonus_unique_huskar_raging_berserker_2")
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
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_huskar_raging_berserker_passive:IsHidden()
	return true
end

modifier_huskar_raging_berserker_effect = class({})
LinkLuaModifier("modifier_huskar_raging_berserker_effect", "heroes/hero_huskar/huskar_raging_berserker", LUA_MODIFIER_MOTION_NONE)

function modifier_huskar_raging_berserker_effect:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("maximum_damage")
	self.mr = self:GetTalentSpecialValueFor("maximum_resistance")
	self.armor = self:GetTalentSpecialValueFor("maximum_armor")
	self.hpThreshold = self:GetTalentSpecialValueFor("hp_threshold_max")
	self.hpPct = math.min(1, (100 - self:GetParent():GetHealthPercent()) / (100 - self.hpThreshold) )
	self:StartIntervalThink(0.3)
	if IsServer() then
		self.glowFX = ParticleManager:CreateParticle("particles/units/heroes/hero_huskar/huskar_berserkers_blood_glow.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
	end
end

function modifier_huskar_raging_berserker_effect:OnRefresh()
	self.damage = self:GetTalentSpecialValueFor("maximum_damage")
	self.mr = self:GetTalentSpecialValueFor("maximum_resistance")
	self.armor = self:GetTalentSpecialValueFor("maximum_armor")
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
	self.total_dmg = self.damage * self.hpPct 
	self.total_mr = self.mr * self.hpPct 
	self.total_armor = self.armor * self.hpPct 
end

function modifier_huskar_raging_berserker_effect:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS, MODIFIER_PROPERTY_MODEL_SCALE}
end

function modifier_huskar_raging_berserker_effect:GetModifierPreAttack_BonusDamage()
	return self.total_dmg
end
function modifier_huskar_raging_berserker_effect:GetModifierPhysicalArmorBonus()
	return self.total_armor
end
function modifier_huskar_raging_berserker_effect:GetModifierMagicalResistanceBonus()
	return self.total_mr
end

function modifier_huskar_raging_berserker_effect:GetModifierModelScale()
	return 35 * self.hpPct
end

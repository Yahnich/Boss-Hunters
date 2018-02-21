huskar_unleash_vitality = class({})

function huskar_unleash_vitality:IsStealable()
	return true
end

function huskar_unleash_vitality:IsHiddenWhenStolen()
	return false
end

function huskar_unleash_vitality:GetIntrinsicModifierName()
	return "modifier_huskar_unleash_vitality_talent"
end

function huskar_unleash_vitality:GetCooldown(iLvl)
	if self:GetCaster():HasTalent("special_bonus_unique_huskar_unleash_vitality_1") then return 0 end
	return self.BaseClass.GetCooldown(self, iLvl)
end

function huskar_unleash_vitality:OnAbilityPhaseStart()
	ParticleManager:FireParticle("particles/units/heroes/hero_huskar/huskar_inner_vitality_cast.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
	return true
end

function huskar_unleash_vitality:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	target:AddNewModifier(caster, self, "modifier_huskar_unleash_vitality_buff", {duration = self:GetTalentSpecialValueFor("duration")})
end


modifier_huskar_unleash_vitality_talent = class({})
LinkLuaModifier("modifier_huskar_unleash_vitality_talent", "heroes/hero_huskar/huskar_unleash_vitality", LUA_MODIFIER_MOTION_NONE)

function modifier_huskar_unleash_vitality_talent:OnCreated()
	self.heal = self:GetTalentSpecialValueFor("heal")
	self.ms = self:GetTalentSpecialValueFor("movespeed")
	self.as = self:GetTalentSpecialValueFor("attackspeed")
	self.bonus_heal = self:GetTalentSpecialValueFor("attrib_bonus_heal") / 100
	self.bonus_ms = self:GetTalentSpecialValueFor("attrib_bonus_ms") / 100
	self.bonus_as = self:GetTalentSpecialValueFor("attrib_bonus_as") / 100
	self.hpPct = self:GetTalentSpecialValueFor("hurt_percent")
	self.hurt_bonus = self:GetTalentSpecialValueFor("hurt_multiplier")
	self.talentMultiplier = self:GetParent():FindTalentValue("special_bonus_unique_huskar_unleash_vitality_2")
	self:StartIntervalThink(0.33)
end

function modifier_huskar_unleash_vitality_talent:OnRefresh()
	self.heal = self:GetTalentSpecialValueFor("heal")
	self.ms = self:GetTalentSpecialValueFor("movespeed")
	self.as = self:GetTalentSpecialValueFor("attackspeed")
	self.bonus_heal = self:GetTalentSpecialValueFor("attrib_bonus_heal") / 100
	self.bonus_ms = self:GetTalentSpecialValueFor("attrib_bonus_ms") / 100
	self.bonus_as = self:GetTalentSpecialValueFor("attrib_bonus_as") / 100
	self.hpPct = self:GetTalentSpecialValueFor("hurt_percent")
	self.hurt_bonus = self:GetTalentSpecialValueFor("hurt_multiplier")
	self.talentMultiplier = self:GetParent():FindTalentValue("special_bonus_unique_huskar_unleash_vitality_2") / 100
end

function modifier_huskar_unleash_vitality_talent:OnIntervalThink()
	self.total_heal = math.floor(self.heal + self:GetParent():GetPrimaryStatValue() * self.bonus_heal) * self.talentMultiplier
	self.total_ms = math.floor(self.ms + self:GetParent():GetPrimaryStatValue() * self.bonus_ms) * self.talentMultiplier
	self.total_as = math.floor(self.as + self:GetParent():GetPrimaryStatValue() * self.bonus_as) * self.talentMultiplier
end

function modifier_huskar_unleash_vitality_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_huskar_unleash_vitality_talent:GetModifierConstantHealthRegen()
	return self.total_heal
end
function modifier_huskar_unleash_vitality_talent:GetModifierMoveSpeedBonus_Constant()
	return self.total_ms
end
function modifier_huskar_unleash_vitality_talent:GetModifierAttackSpeedBonus_Constant()
	return self.total_as
end

function modifier_huskar_unleash_vitality_talent:IsHidden()
	return not self:GetCaster():HasTalent("special_bonus_unique_huskar_unleash_vitality_2")
end

modifier_huskar_unleash_vitality_buff = class({})
LinkLuaModifier("modifier_huskar_unleash_vitality_buff", "heroes/hero_huskar/huskar_unleash_vitality", LUA_MODIFIER_MOTION_NONE)

function modifier_huskar_unleash_vitality_buff:OnCreated()
	self.heal = self:GetTalentSpecialValueFor("heal")
	self.ms = self:GetTalentSpecialValueFor("movespeed")
	self.as = self:GetTalentSpecialValueFor("attackspeed")
	self.bonus_heal = self:GetTalentSpecialValueFor("attrib_bonus_heal") / 100
	self.bonus_ms = self:GetTalentSpecialValueFor("attrib_bonus_ms") / 100
	self.bonus_as = self:GetTalentSpecialValueFor("attrib_bonus_as") / 100
	self.hpPct = self:GetTalentSpecialValueFor("hurt_percent")
	self.hurt_bonus = self:GetTalentSpecialValueFor("hurt_multiplier")
	self.talentMultiplier = self:GetParent():FindTalentValue("special_bonus_unique_huskar_unleash_vitality_2")
	self:StartIntervalThink(0.33)
	
	self.total_heal = math.floor(self.heal + self:GetParent():GetPrimaryStatValue() * self.bonus_heal)
	self.total_ms = math.floor(self.ms + self:GetParent():GetPrimaryStatValue() * self.bonus_ms)
	self.total_as = math.floor(self.as + self:GetParent():GetPrimaryStatValue() * self.bonus_as)
end

function modifier_huskar_unleash_vitality_buff:OnRefresh()
	self.heal = self:GetTalentSpecialValueFor("heal")
	self.ms = self:GetTalentSpecialValueFor("movespeed")
	self.as = self:GetTalentSpecialValueFor("attackspeed")
	self.bonus_heal = self:GetTalentSpecialValueFor("attrib_bonus_heal") / 100
	self.bonus_ms = self:GetTalentSpecialValueFor("attrib_bonus_ms") / 100
	self.bonus_as = self:GetTalentSpecialValueFor("attrib_bonus_as") / 100
	self.hpPct = self:GetTalentSpecialValueFor("hurt_percent")
	self.hurt_bonus = self:GetTalentSpecialValueFor("hurt_multiplier")
	
	self.total_heal = math.floor(self.heal + self:GetParent():GetPrimaryStatValue() * self.bonus_heal)
	self.total_ms = math.floor(self.ms + self:GetParent():GetPrimaryStatValue() * self.bonus_ms)
	self.total_as = math.floor(self.as + self:GetParent():GetPrimaryStatValue() * self.bonus_as)
end

function modifier_huskar_unleash_vitality_buff:OnIntervalThink()
	self.total_heal = math.floor(self.heal + self:GetParent():GetPrimaryStatValue() * self.bonus_heal)
	self.total_ms = math.floor(self.ms + self:GetParent():GetPrimaryStatValue() * self.bonus_ms)
	self.total_as = math.floor(self.as + self:GetParent():GetPrimaryStatValue() * self.bonus_as)
end


function modifier_huskar_unleash_vitality_buff:DeclareFunctions()
	return {MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
end

function modifier_huskar_unleash_vitality_buff:GetModifierConstantHealthRegen()
	return self.total_heal
end

function modifier_huskar_unleash_vitality_buff:GetModifierMoveSpeedBonus_Constant()
	return self.total_ms
end

function modifier_huskar_unleash_vitality_buff:GetModifierAttackSpeedBonus_Constant()
	return self.total_as
end

function modifier_huskar_unleash_vitality_buff:GetEffectName()
	return "particles/units/heroes/hero_huskar/huskar_inner_vitality.vpcf"
end
alchemist_chemical_rage_ebf = class({})

function alchemist_chemical_rage_ebf:IsStealable()
	return true
end

function alchemist_chemical_rage_ebf:IsHiddenWhenStolen()
	return false
end

function alchemist_chemical_rage_ebf:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("Hero_Alchemist.ChemicalRage.Cast", caster)
	caster:AddNewModifier(caster, self, "modifier_alchemist_chemical_rage_ebf", {duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_alchemist_chemical_rage_ebf = class({})
LinkLuaModifier("modifier_alchemist_chemical_rage_ebf", "heroes/hero_alchemist/alchemist_chemical_rage_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_alchemist_chemical_rage_ebf:OnCreated()
	self.bat = self:GetTalentSpecialValueFor("base_attack_time")
	self.hp = self:GetTalentSpecialValueFor("bonus_hp")
	self.hpr = self:GetTalentSpecialValueFor("bonus_health_regen")
	self.mpr = self:GetTalentSpecialValueFor("bonus_mana_regen")
	self.ms = self:GetTalentSpecialValueFor("bonus_movespeed")
	if IsServer() then EmitSoundOn("Hero_Alchemist.ChemicalRage", self:GetParent()) end
end

function modifier_alchemist_chemical_rage_ebf:OnRefresh()
	self.bat = self:GetTalentSpecialValueFor("base_attack_time")
	self.hp = self:GetTalentSpecialValueFor("bonus_hp")
	self.hpr = self:GetTalentSpecialValueFor("bonus_health_regen")
	self.mpr = self:GetTalentSpecialValueFor("bonus_mana_regen")
	self.ms = self:GetTalentSpecialValueFor("bonus_movespeed")
end

function modifier_alchemist_chemical_rage_ebf:OnDestroy()
	if IsServer() then StopSoundOn("Hero_Alchemist.ChemicalRage", self:GetParent()) end
end

function modifier_alchemist_chemical_rage_ebf:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
			MODIFIER_PROPERTY_HEALTH_BONUS,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS}
end


function modifier_alchemist_chemical_rage_ebf:GetModifierBaseAttackTimeConstant()
	return self.bat
end

function modifier_alchemist_chemical_rage_ebf:GetModifierHealthBonus()
	return self.hp
end

function modifier_alchemist_chemical_rage_ebf:GetModifierConstantHealthRegen()
	return self.hpr
end

function modifier_alchemist_chemical_rage_ebf:GetModifierConstantManaRegen()
	return self.mpr
end

function modifier_alchemist_chemical_rage_ebf:GetModifierMoveSpeedBonus_Constant()
	return self.ms
end

function modifier_alchemist_chemical_rage_ebf:GetActivityTranslationModifiers()
	return "chemical_rage"
end

function modifier_alchemist_chemical_rage_ebf:GetEffectName()
	return "particles/units/heroes/hero_alchemist/alchemist_chemical_rage.vpcf"
end

function modifier_alchemist_chemical_rage_ebf:GetHeroEffectName()
	return "particles/units/heroes/hero_alchemist/alchemist_chemical_rage_hero_effect.vpcf"
end

function modifier_alchemist_chemical_rage_ebf:HeroEffectPriority()
	return 10
end

function modifier_alchemist_chemical_rage_ebf:AllowIllusionDuplicate()
	return true
end
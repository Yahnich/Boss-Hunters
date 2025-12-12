alchemist_chemical_rage_bh = class({})

function alchemist_chemical_rage_bh:IsStealable()
	return true
end

function alchemist_chemical_rage_bh:IsHiddenWhenStolen()
	return false
end

function alchemist_chemical_rage_bh:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("Hero_Alchemist.ChemicalRage.Cast", caster)
	caster:AddNewModifier(caster, self, "modifier_alchemist_chemical_rage_bh", {duration = self:GetSpecialValueFor("duration")})
end

modifier_alchemist_chemical_rage_bh = class({})
LinkLuaModifier("modifier_alchemist_chemical_rage_bh", "heroes/hero_alchemist/alchemist_chemical_rage_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_alchemist_chemical_rage_bh:OnCreated()
	self.bat = self:GetSpecialValueFor("base_attack_time")
	self.hp = self:GetSpecialValueFor("bonus_hp")
	self.hpr = self:GetSpecialValueFor("bonus_health_regen")
	self.mpr = self:GetSpecialValueFor("bonus_mana_regen")
	self.ms = self:GetSpecialValueFor("bonus_movespeed")
	self:GetParent():HookInModifier("GetBaseAttackTime_Bonus", self)
	if IsServer() then
		Timers:CreateTimer( function() self:GetCaster():HealEvent( self.hp, self:GetAbility(), self:GetCaster() ) end )
		EmitSoundOn("Hero_Alchemist.ChemicalRage", self:GetParent()) 
	end
end

function modifier_alchemist_chemical_rage_bh:OnRefresh()
	self.bat = self:GetSpecialValueFor("base_attack_time")
	self.hp = self:GetSpecialValueFor("bonus_hp")
	self.hpr = self:GetSpecialValueFor("bonus_health_regen")
	self.mpr = self:GetSpecialValueFor("bonus_mana_regen")
	self:GetParent():HookInModifier("GetBaseAttackTime_Bonus", self)
	self.ms = self:GetSpecialValueFor("bonus_movespeed")
	if IsServer() then
		Timers:CreateTimer( function() self:GetCaster():HealEvent( self.hp, self:GetAbility(), self:GetCaster() ) end )
	end
end

function modifier_alchemist_chemical_rage_bh:OnDestroy()
	self:GetParent():HookOutModifier("GetBaseAttackTime_Bonus", self)
	if IsServer() then StopSoundOn("Hero_Alchemist.ChemicalRage", self:GetParent()) end
end

function modifier_alchemist_chemical_rage_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
			MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS}
end


function modifier_alchemist_chemical_rage_bh:GetBaseAttackTime_Bonus()
	return self.bat
end

function modifier_alchemist_chemical_rage_bh:GetModifierExtraHealthBonus()
	return self.hp
end

function modifier_alchemist_chemical_rage_bh:GetModifierConstantHealthRegen()
	return self.hpr
end

function modifier_alchemist_chemical_rage_bh:GetModifierConstantManaRegen()
	return self.mpr
end

function modifier_alchemist_chemical_rage_bh:GetModifierMoveSpeedBonus_Constant()
	return self.ms
end

function modifier_alchemist_chemical_rage_bh:GetActivityTranslationModifiers()
	return "chemical_rage"
end

function modifier_alchemist_chemical_rage_bh:GetEffectName()
	return "particles/units/heroes/hero_alchemist/alchemist_chemical_rage.vpcf"
end

function modifier_alchemist_chemical_rage_bh:GetHeroEffectName()
	return "particles/units/heroes/hero_alchemist/alchemist_chemical_rage_hero_effect.vpcf"
end

function modifier_alchemist_chemical_rage_bh:HeroEffectPriority()
	return 10
end

function modifier_alchemist_chemical_rage_bh:AllowIllusionDuplicate()
	return true
end
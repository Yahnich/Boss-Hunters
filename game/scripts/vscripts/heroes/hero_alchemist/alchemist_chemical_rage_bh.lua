alchemist_rage_injector = class({})

function alchemist_rage_injector:IsStealable()
	return true
end

function alchemist_rage_injector:IsHiddenWhenStolen()
	return false
end

function alchemist_rage_injector:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("Hero_Alchemist.ChemicalRage.Cast", caster)
	caster:AddNewModifier(caster, self, "modifier_alchemist_rage_injector", {duration = self:GetSpecialValueFor("duration")})
end

modifier_alchemist_rage_injector = class({})
LinkLuaModifier("modifier_alchemist_rage_injector", "heroes/hero_alchemist/alchemist_rage_injector", LUA_MODIFIER_MOTION_NONE)

function modifier_alchemist_rage_injector:OnCreated()
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

function modifier_alchemist_rage_injector:OnRefresh()
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

function modifier_alchemist_rage_injector:OnDestroy()
	self:GetParent():HookOutModifier("GetBaseAttackTime_Bonus", self)
	if IsServer() then StopSoundOn("Hero_Alchemist.ChemicalRage", self:GetParent()) end
end

function modifier_alchemist_rage_injector:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
			MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS}
end


function modifier_alchemist_rage_injector:GetBaseAttackTime_Bonus()
	return self.bat
end

function modifier_alchemist_rage_injector:GetModifierExtraHealthBonus()
	return self.hp
end

function modifier_alchemist_rage_injector:GetModifierConstantHealthRegen()
	return self.hpr
end

function modifier_alchemist_rage_injector:GetModifierConstantManaRegen()
	return self.mpr
end

function modifier_alchemist_rage_injector:GetModifierMoveSpeedBonus_Constant()
	return self.ms
end

function modifier_alchemist_rage_injector:GetActivityTranslationModifiers()
	return "chemical_rage"
end

function modifier_alchemist_rage_injector:GetEffectName()
	return "particles/units/heroes/hero_alchemist/alchemist_chemical_rage.vpcf"
end

function modifier_alchemist_rage_injector:GetHeroEffectName()
	return "particles/units/heroes/hero_alchemist/alchemist_chemical_rage_hero_effect.vpcf"
end

function modifier_alchemist_rage_injector:HeroEffectPriority()
	return 10
end

function modifier_alchemist_rage_injector:AllowIllusionDuplicate()
	return true
end
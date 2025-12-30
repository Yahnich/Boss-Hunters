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
	self:OnRefresh()
	self:GetParent():HookInModifier("GetBaseAttackTime_Bonus", self)
	if IsServer() then
		EmitSoundOn("Hero_Alchemist.ChemicalRage", self:GetParent()) 
	end
end

function modifier_alchemist_rage_injector:OnRefresh()
	self.bat = self:GetSpecialValueFor("base_attack_time")
	self.bonus_hp = self:GetSpecialValueFor("bonus_hp")
	self.bonus_hp_per_materia = self:GetSpecialValueFor("bonus_hp_per_materia")
	self.bonus_health_regen = self:GetSpecialValueFor("bonus_health_regen")
	self.bonus_health_regen_per_materia = self:GetSpecialValueFor("bonus_health_regen_per_materia")
	self.bonus_movespeed = self:GetSpecialValueFor("bonus_movespeed")
	
	self.bonus_armor_per_materia = self:GetSpecialValueFor("bonus_armor_per_materia")
	self.bonus_damage_per_materia = self:GetSpecialValueFor("bonus_damage_per_materia")
	if IsServer() then
		Timers:CreateTimer( function() self:GetCaster():HealEvent( self.bonus_hp, self:GetAbility(), self:GetCaster() ) end )
		self:GetParent():CalculateStatBonus( false )
	end
end

function modifier_alchemist_rage_injector:OnDestroy()
	self:GetParent():HookOutModifier("GetBaseAttackTime_Bonus", self)
	if IsServer() then StopSoundOn("Hero_Alchemist.ChemicalRage", self:GetParent()) end
end

function modifier_alchemist_rage_injector:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
			MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS}
end


function modifier_alchemist_rage_injector:GetBaseAttackTime_Bonus()
	return self.bat
end

function modifier_alchemist_rage_injector:GetModifierExtraHealthBonus()
	return self.bonus_hp + self.bonus_hp_per_materia * self:GetParent():GetModifierStackCount( "modifier_alchemist_chymistry_passive", self:GetCaster() )
end

function modifier_alchemist_rage_injector:GetModifierConstantHealthRegen()
	return self.bonus_health_regen + self.bonus_health_regen_per_materia * self:GetParent():GetModifierStackCount( "modifier_alchemist_chymistry_passive", self:GetCaster() )
end

function modifier_alchemist_rage_injector:GetModifierMoveSpeedBonus_Constant()
	return self.bonus_movespeed
end

function modifier_alchemist_rage_injector:GetModifierPhysicalArmorBonus()
	return self.bonus_armor_per_materia * self:GetParent():GetModifierStackCount( "modifier_alchemist_chymistry_passive", self:GetCaster() )
end

function modifier_alchemist_rage_injector:GetModifierBaseAttack_BonusDamage()
	return self.bonus_damage_per_materia * self:GetParent():GetModifierStackCount( "modifier_alchemist_chymistry_passive", self:GetCaster() )
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
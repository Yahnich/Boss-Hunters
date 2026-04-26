alchemist_spark_of_genius = class({})

function alchemist_spark_of_genius:IsStealable()
	return true
end

function alchemist_spark_of_genius:IsHiddenWhenStolen()
	return false
end

function alchemist_spark_of_genius:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn("Hero_Alchemist.ChemicalRage.Cast", caster)
	caster:AddNewModifier(caster, self, "modifier_alchemist_spark_of_genius", {duration = self:GetSpecialValueFor("duration")})
end

modifier_alchemist_spark_of_genius = class({})
LinkLuaModifier("modifier_alchemist_spark_of_genius", "heroes/hero_alchemist/alchemist_spark_of_genius", LUA_MODIFIER_MOTION_NONE)

function modifier_alchemist_spark_of_genius:OnCreated()
	self:GetParent():HookInModifier("GetModifierAoEBonusConstantStacking", self)
	self:OnRefresh()
end

function modifier_alchemist_spark_of_genius:OnRefresh()
	self.status_amp = self:GetSpecialValueFor("status_amp")
	self.spell_amp = self:GetSpecialValueFor("spell_amp")
	self.bonus_radius = self:GetSpecialValueFor("bonus_radius")
end

function modifier_alchemist_rage_injector:OnDestroy()
	self:GetParent():HookOutModifier("GetModifierAoEBonusConstantStacking", self)
end

function modifier_alchemist_spark_of_genius:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
			MODIFIER_PROPERTY_TOOLTIP,
			MODIFIER_PROPERTY_AOE_BONUS_CONSTANT_STACKING}
end


function modifier_alchemist_spark_of_genius:GetModifierSpellAmplify_Percentage()
	return self.spell_amp
end

function modifier_alchemist_spark_of_genius:GetModifierStatusAmplify_Percentage()
	return self.status_amp
end

function modifier_alchemist_spark_of_genius:GetModifierAoEBonusConstantStacking()
	return self.bonus_radius
end

function modifier_alchemist_spark_of_genius:OnTooltip()
	return self.status_amp
end

function modifier_alchemist_spark_of_genius:GetEffectName()
	return "particles/units/heroes/hero_alchemist/alchemist_chemical_rage.vpcf"
end

function modifier_alchemist_spark_of_genius:GetHeroEffectName()
	return "particles/units/heroes/hero_alchemist/alchemist_chemical_rage_hero_effect.vpcf"
end

function modifier_alchemist_spark_of_genius:HeroEffectPriority()
	return 10
end

function modifier_alchemist_spark_of_genius:AllowIllusionDuplicate()
	return true
end
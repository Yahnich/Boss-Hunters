night_stalker_dark_ascension_bh = class({})

function night_stalker_dark_ascension_bh:OnSpellStart()
	local caster = self:GetCaster()
	local dark_ascension = caster:AddNewModifier(caster, self, "modifier_night_stalker_dark_ascension_bh", {duration = self:GetSpecialValueFor("duration")})

	ParticleManager:FireParticle("particles/units/heroes/hero_night_stalker/nightstalker_ulti.vpcf", PATTACH_POINT_FOLLOW, caster)
	EmitGlobalSound("Hero_Nightstalker.Darkness.Team")
end

modifier_night_stalker_dark_ascension_bh = class({})
LinkLuaModifier("modifier_night_stalker_dark_ascension_bh", "heroes/hero_night_stalker/night_stalker_dark_ascension_bh", LUA_MODIFIER_MOTION_NONE)

function modifier_night_stalker_dark_ascension_bh:OnCreated()
	self.damage = self:GetSpecialValueFor("bonus_damage")
	if IsServer() then
		GameRules:BeginNightstalkerNight( self:GetRemainingTime() )
	end
end
	
function modifier_night_stalker_dark_ascension_bh:OnRefresh()
	self.damage = self:GetSpecialValueFor("bonus_damage")
	if IsServer() then
		GameRules:BeginNightstalkerNight( self:GetRemainingTime() )
	end
end

function modifier_night_stalker_dark_ascension_bh:CheckState()
	return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
end

function modifier_night_stalker_dark_ascension_bh:DeclareFunctions()
	return {MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_night_stalker_dark_ascension_bh:GetActivityTranslationModifiers()
	return "haste"
end

function modifier_night_stalker_dark_ascension_bh:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function night_stalker_dark_ascension_bh:GetHeroEffectName()
	return "particles/units/heroes/hero_night_stalker/nightstalker_dark_ascension_hero_effect.vpcf"
end

function night_stalker_dark_ascension_bh:HeroEffectPriority()
	return 10
end

function modifier_night_stalker_dark_ascension_bh:IsPurgable()
	return false
end

function modifier_night_stalker_dark_ascension_bh:RemoveOnDeath()
	return false
end
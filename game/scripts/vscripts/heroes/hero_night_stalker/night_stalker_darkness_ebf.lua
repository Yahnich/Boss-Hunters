night_stalker_darkness_ebf = class({})

function night_stalker_darkness_ebf:OnSpellStart()
	local caster = self:GetCaster()
	local darkness = caster:AddNewModifier(caster, self, "modifier_night_stalker_darkness_ebf", {duration = self:GetTalentSpecialValueFor("duration")})
	darkness:OnRefresh() -- WTF????? WHY CANT I CALL ONCREATED WHAT THE FUCK
	ParticleManager:FireParticle("particles/units/heroes/hero_night_stalker/nightstalker_ulti.vpcf", PATTACH_POINT_FOLLOW, caster)
	EmitGlobalSound("Hero_Nightstalker.Darkness.Team")
end

modifier_night_stalker_darkness_ebf = class({})
LinkLuaModifier("modifier_night_stalker_darkness_ebf", "heroes/hero_night_stalker/night_stalker_darkness_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_night_stalker_darkness_ebf:OnCreated()
	print("WHY ARENT YOU WORKING")
	if IsServer() then
		GameRules:BeginNightstalkerNight( self:GetRemainingTime() )
	end
end
	
function modifier_night_stalker_darkness_ebf:OnRefresh()
	if IsServer() then
		GameRules:BeginNightstalkerNight( self:GetRemainingTime() )
	end
end

function modifier_night_stalker_darkness_ebf:IsAura()
	return true
end

function modifier_night_stalker_darkness_ebf:GetModifierAura()
	return "modifier_night_stalker_darkness_ebf_aura"
end

function modifier_night_stalker_darkness_ebf:GetAuraRadius()
	return -1
end

function modifier_night_stalker_darkness_ebf:GetAuraDuration()
	return 0.5
end

function modifier_night_stalker_darkness_ebf:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_night_stalker_darkness_ebf:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_night_stalker_darkness_ebf:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function night_stalker_darkness_ebf:GetHeroEffectName()
	return "particles/units/heroes/hero_night_stalker/nightstalker_darkness_hero_effect.vpcf"
end

function night_stalker_darkness_ebf:HeroEffectPriority()
	return 10
end

function modifier_night_stalker_darkness_ebf:IsPurgable()
	return false
end

function modifier_night_stalker_darkness_ebf:RemoveOnDeath()
	return false
end

modifier_night_stalker_darkness_ebf_aura = class({})
LinkLuaModifier("modifier_night_stalker_darkness_ebf_aura", "heroes/hero_night_stalker/night_stalker_darkness_ebf", LUA_MODIFIER_MOTION_NONE)

function modifier_night_stalker_darkness_ebf:OnCreated()
	self.blind = self:GetTalentSpecialValueFor("blind_percentage")
end

function modifier_night_stalker_darkness_ebf_aura:DeclareFunctions()
	return {MODIFIER_PROPERTY_MISS_PERCENTAGE}
end

function modifier_night_stalker_darkness_ebf_aura:GetModifierMiss_Percentage()
	return self.blind
end
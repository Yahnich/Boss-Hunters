night_stalker_stalkers_eyes = class({})

function night_stalker_stalkers_eyes:GetIntrinsicModifierName()
	return "modifier_night_stalker_stalkers_eyes"
end

modifier_night_stalker_stalkers_eyes = class({})
LinkLuaModifier("modifier_night_stalker_stalkers_eyes", "heroes/hero_night_stalker/night_stalker_stalkers_eyes", LUA_MODIFIER_MOTION_NONE)

function modifier_night_stalker_stalkers_eyes:OnCreated()	
	if IsServer() then
		self:StartIntervalThink(0)
	end
end

function modifier_night_stalker_stalkers_eyes:OnIntervalThink()
	if not GameRules:IsDaytime() or GameRules:IsNightstalkerNight() or GameRules:IsTemporaryNight() then
		AddFOWViewer( self:GetParent():GetTeam(), self:GetParent():GetAbsOrigin(), self:GetParent():GetNightTimeVisionRange(), 0.1, false)
	end
end

function modifier_night_stalker_stalkers_eyes:IsHidden()
	return true
end

function modifier_night_stalker_stalkers_eyes:IsPurgable()
	return false
end

function modifier_night_stalker_stalkers_eyes:RemoveOnDeath()
	return false
end

function modifier_night_stalker_stalkers_eyes:IsPermanent()
	return true
end

function modifier_night_stalker_stalkers_eyes:AllowIllusionDuplicate()
	return true
end

function modifier_night_stalker_stalkers_eyes:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
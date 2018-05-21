HP_PER_STR = 18
MR_PER_STR = 0.4
HP_REGEN_PER_STR = 0.025
MANA_PER_INT = 10
MANA_REGEN_PER_INT = 0.035
ARMOR_PER_AGI = 0.07
ATKSPD_PER_AGI = 0.08
DMG_PER_AGI = 0.5
CDR_PER_INT = 0.385
SPELL_AMP_PER_INT = 0.0075

if IsClient() then -- Load clientside utility lib
	if GameRules == nil then
		GameRules = class({})
	end
	print(GameRules, "?")
	print("client-side has been initialized")
	require("libraries/client_util")
	print(GameRules.IsDaytime, "?")
end

relicBaseClass = class({})

function relicBaseClass:IsHidden()
	return true
end

function relicBaseClass:DestroyOnExpire()
	return false
end

function relicBaseClass:IsPurgable()
	return false
end

function relicBaseClass:RemoveOnDeath()
	return false
end

function relicBaseClass:IsPermanent()
	return true
end

function relicBaseClass:AllowIllusionDuplicate()
	return true
end

-- function relicBaseClass:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT + MODIFIER_ATTRIBUTE_MULTIPLE
end
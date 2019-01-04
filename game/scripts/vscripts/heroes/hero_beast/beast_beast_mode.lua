beast_beast_mode = class({})
LinkLuaModifier( "modifier_beast_mode", "heroes/hero_beast/beast_beast_mode.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_beast_mode_allies", "heroes/hero_beast/beast_beast_mode.lua" ,LUA_MODIFIER_MOTION_NONE )

function beast_beast_mode:GetIntrinsicModifierName()
	return "modifier_beast_mode"
end

modifier_beast_mode = class({})
function modifier_beast_mode:GetAuraDuration()
	return 1.0
end

function modifier_beast_mode:GetAuraRadius()
	return self:GetSpecialValueFor("radius")
end

function modifier_beast_mode:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_beast_mode:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_beast_mode:GetAuraSearchType()
	return DOTA_UNIT_TARGET_ALL
end

function modifier_beast_mode:GetModifierAura()
	return "modifier_beast_mode_allies"
end

function modifier_beast_mode:IsAura()
	return true
end

function modifier_beast_mode:IsHidden()
	return true
end

modifier_beast_mode_allies = class({})
function modifier_beast_mode_allies:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
	}
	return funcs
end

function modifier_beast_mode_allies:GetCooldownReduction()
	return self:GetTalentSpecialValueFor("bonus_cdr")
end

function modifier_beast_mode_allies:GetModifierAttackSpeedBonus()
	return self:GetTalentSpecialValueFor("bonus_attackspeed")
end

function modifier_beast_mode_allies:GetModifierSpellAmplify_Percentage()
	if self:GetCaster():HasTalent("special_bonus_unique_beast_beast_mode_1") then return self:GetTalentSpecialValueFor("bonus_cdr") end
end

function modifier_beast_mode_allies:IsDebuff()
	return false
end
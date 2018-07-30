luna_lunar_blessing_bh = class({})

function luna_lunar_blessing_bh:GetIntrinsicModifierName()
	return "modifier_luna_lunar_blessing_passive"
end

LinkLuaModifier( "modifier_luna_lunar_blessing_passive", "lua_abilities/heroes/luna.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_luna_lunar_blessing_passive = class({})

function modifier_luna_lunar_blessing_passive:OnCreated()
	self.aura_radius = self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_luna_lunar_blessing_passive:OnRefresh()
	self.aura_radius = self:GetAbility():GetSpecialValueFor("radius")
end

function modifier_luna_lunar_blessing_passive:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_luna_lunar_blessing_passive:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_luna_lunar_blessing_passive:GetModifierAura()
	return "modifier_luna_lunar_blessing_aura"
end

--------------------------------------------------------------------------------

function modifier_luna_lunar_blessing_passive:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

--------------------------------------------------------------------------------

function modifier_luna_lunar_blessing_passive:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

--------------------------------------------------------------------------------

function modifier_luna_lunar_blessing_passive:GetAuraRadius()
	return self.aura_radius
end

--------------------------------------------------------------------------------
function modifier_luna_lunar_blessing_passive:IsPurgable()
    return false
end

LinkLuaModifier( "modifier_luna_lunar_blessing_aura", "lua_abilities/heroes/luna.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_luna_lunar_blessing_aura = class({})

function modifier_luna_lunar_blessing_aura:OnCreated()
    self.damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.dmg_pct = self:GetAbility():GetSpecialValueFor("bonus_damage_pct")
end

function modifier_luna_lunar_blessing_aura:OnRefresh()
    self.damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
	self.dmg_pct = self:GetAbility():GetSpecialValueFor("bonus_damage_pct")
end

function modifier_luna_lunar_blessing_aura:DeclareFunctions()
	funcs = {
				MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
				MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
				MODIFIER_PROPERTY_ATTACKSPEED_BONUS,
				MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
				,
			}
	return funcs
end

function modifier_luna_lunar_blessing_aura:GetModifierPreAttack_BonusDamage()
    return self.damage
end

function modifier_luna_lunar_blessing_aura:AS()
    return self:GetCaster():FindTalentValue("special_bonus_unique_luna_lunar_blessing_2", "as")
end

function modifier_luna_lunar_blessing_aura:MS()
    return self:GetCaster():FindTalentValue("special_bonus_unique_luna_lunar_blessing_2", "ms")
end

function modifier_luna_lunar_blessing_aura:GetModifierBaseDamageOutgoing_Percentage()
	if not GameRules:IsDaytime() then return self.dmg_pct end
end
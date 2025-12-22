alchemist_greevils_greed = class({})

function alchemist_greevils_greed:GetIntrinsicModifierName()
	return "modifier_alchemist_greevils_greed_passive"
end

modifier_alchemist_greevils_greed_passive = class({})
LinkLuaModifier( "modifier_alchemist_greevils_greed_passive", "heroes/hero_alchemist/alchemist_greevils_greed", LUA_MODIFIER_MOTION_NONE )

function modifier_alchemist_greevils_greed_passive:IsHidden()
    return false
end
function modifier_alchemist_greevils_greed_passive:IsBuff()
    return true
end
function modifier_alchemist_greevils_greed_passive:IsPurgable()
    return false
end
function modifier_alchemist_greevils_greed_passive:RemoveOnDeath()
    return false
end
function modifier_alchemist_greevils_greed_passive:IsAura()
	return self:GetSpecialValueFor("allied_bonus_gold") ~= 0
end
function modifier_alchemist_greevils_greed_passive:IsAuraActiveOnDeath()
    return self:GetSpecialValueFor("allied_bonus_gold") ~= 0
end
function modifier_alchemist_greevils_greed_passive:GetModifierAura()
	return "modifier_alchemist_greevils_greed_chrysopoeia"
end
function modifier_alchemist_greevils_greed_passive:GetAuraRadius()
	return 99999
end
function modifier_alchemist_greevils_greed_passive:GetAuraDuration()
	return 0.5
end
function modifier_alchemist_greevils_greed_passive:GetAuraEntityReject(target)
	return target == self:GetCaster()
end
function modifier_alchemist_greevils_greed_passive:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY 
end
function modifier_alchemist_greevils_greed_passive:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end
function modifier_alchemist_greevils_greed_passive:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end
function modifier_alchemist_greevils_greed_passive:OnCreated()
    self:SetHasCustomTransmitterData(true)
    self:OnRefresh()
end
function modifier_alchemist_greevils_greed_passive:OnRefresh()
    self.spell_amplification = self:GetSpecialValueFor("spell_amplification")
    self.healing_provided = self:GetSpecialValueFor("healing_provided")
    self.bonus_damage = self:GetSpecialValueFor("bonus_damage")
    self.attack_speed = self:GetSpecialValueFor("attack_speed")
    self.gold_threshold = self:GetSpecialValueFor("gold_threshold")
    self.bonus_gold = self:GetSpecialValueFor("bonus_gold")
    if IsClient() then return end
    self:StartIntervalThink(1.0)
end
function modifier_alchemist_greevils_greed_passive:OnIntervalThink()
    self:SendBuffRefreshToClients()
end
function modifier_alchemist_greevils_greed_passive:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_TOOLTIP
    }
end
function modifier_alchemist_greevils_greed_passive:GetModifierSpellAmplify_Percentage()
    return self.spell_amplification * self.gold / self.gold_threshold
end
function modifier_alchemist_greevils_greed_passive:GetModifierHPRegenAmplify_Percentage()
    return self.healing_provided * self.gold / self.gold_threshold
end
function modifier_alchemist_greevils_greed_passive:GetModifierLifestealRegenAmplify_Percentage()
    return self.healing_provided * self.gold / self.gold_threshold
end
function modifier_alchemist_greevils_greed_passive:GetModifierSpellLifestealRegenAmplify_Percentage()
    return self.healing_provided * self.gold / self.gold_threshold
end
function modifier_alchemist_greevils_greed_passive:GetModifierBaseDamageOutgoing_Percentage()
    return self.bonus_damage * self.gold / self.gold_threshold
end
function modifier_alchemist_greevils_greed_passive:GetModifierAttackSpeedBonus_Constant()
    return self.attack_speed * self.gold / self.gold_threshold
end
function modifier_alchemist_greevils_greed_passive:OnTooltip()
    return self.bonus_gold
end
function modifier_alchemist_greevils_greed_passive:AddCustomTransmitterData()
    self.gold = self:GetParent():GetGold()
    return {
        gold = tonumber(self.gold)
    }
end
function modifier_alchemist_greevils_greed_passive:HandleCustomTransmitterData(data)
    self.gold = tonumber(data.gold)
end

modifier_alchemist_greevils_greed_chrysopoeia = class({})
LinkLuaModifier( "modifier_alchemist_greevils_greed_chrysopoeia", "heroes/hero_alchemist/alchemist_greevils_greed", LUA_MODIFIER_MOTION_NONE )

function modifier_alchemist_greevils_greed_chrysopoeia:IsHidden()
    return false
end
function modifier_alchemist_greevils_greed_chrysopoeia:IsBuff()
    return true
end
function modifier_alchemist_greevils_greed_chrysopoeia:IsPurgable()
    return false
end
function modifier_alchemist_greevils_greed_chrysopoeia:OnCreated()
    self:OnRefresh()
end
function modifier_alchemist_greevils_greed_chrysopoeia:OnRefresh()
    self.allied_bonus_gold = self:GetSpecialValueFor("allied_bonus_gold")
end
function modifier_alchemist_greevils_greed_chrysopoeia:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOOLTIP
    }
end
function modifier_alchemist_greevils_greed_chrysopoeia:OnTooltip()
    return self:GetSpecialValueFor("allied_bonus_gold")
end
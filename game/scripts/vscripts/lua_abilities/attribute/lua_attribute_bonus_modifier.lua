if lua_attribute_bonus_modifier == nil then
	lua_attribute_bonus_modifier = class({})
end

function lua_attribute_bonus_modifier:DeclareFunctions()
	local funcs = {
MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
MODIFIER_EVENT_ON_HEALTH_GAINED,
MODIFIER_EVENT_ON_HEAL_RECEIVED,
	}
	return funcs
end

function lua_attribute_bonus_modifier:OnCreated()
	self.agiamp = 80 -- 1% per 80 agi
	if IsServer() then
		local parent = self:GetAbility()
		local strength = self:GetModifierBonusStats_All(0, self:GetParent():GetStrengthGain())
		local agility = self:GetModifierBonusStats_All(1, self:GetParent():GetAgilityGain())
		local intellect = self:GetModifierBonusStats_All(2, self:GetParent():GetIntellectGain())
		self:GetParent():SetBaseStrength(self:GetParent():GetBaseStrength() + strength )
		self:GetParent():SetBaseAgility(self:GetParent():GetBaseAgility() + agility ) 
		self:GetParent():SetBaseIntellect(self:GetParent():GetBaseIntellect() + intellect )
	end
end


function lua_attribute_bonus_modifier:IsHidden()
	return true
end

function lua_attribute_bonus_modifier:GetAttributes() 
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function lua_attribute_bonus_modifier:AllowIllusionDuplicate()
	return true
end

function lua_attribute_bonus_modifier:GetModifierBonusStats_All(nType, nBonus)
	local hAbility = self:GetAbility()
	local nLevel = hAbility:GetLevel()
	local nStats = (1.117^nLevel * nBonus + nLevel^0.3 * 10) / 2
	if self:GetParent():GetPrimaryAttribute() == nType then 
		return math.floor(nStats * 1.2)
	else
		return nStats
	end
end

function lua_attribute_bonus_modifier:OnHealReceived (keys)
    if IsServer and keys.unit == self:GetParent() then
		if not keys.process_procs and not self.healed then
            if self:GetParent():IsRealHero() and keys.unit:IsRealHero() then
				local agihealamp = self:GetParent():GetAgility()/(100*self.agiamp)
                local _heal = keys.gain * agihealamp
				local hp = self:GetParent():GetHealth()
                self:GetParent():SetHealth(hp + _heal)
            end
        end
    end
end
sniper_rangefinder = class({})

function sniper_rangefinder:GetIntrinsicModifierName()
    return "modifier_sniper_rangefinder"
end

function sniper_rangefinder:OnHeroLevelUp()
	self._innateModifier:ForceRefresh()
end

modifier_sniper_rangefinder = class({})
LinkLuaModifier("modifier_sniper_rangefinder", "heroes/hero_sniper/sniper_rangefinder", LUA_MODIFIER_MOTION_NONE)

function modifier_sniper_rangefinder:IsHidden()
    return true
end

function modifier_sniper_rangefinder:OnCreated()
    self:OnRefresh()
	
	local abilityKeyValues = GetAbilityKeyValuesByName( self:GetAbility():GetAbilityName() )
	self.bonus_attack_speed_level = tonumber( abilityKeyValues.AbilityValues["bonus_attack_speed"].special_bonus_facet_sniper_gunslinger["hero_levelup"] )
	
	self:GetAbility()._innateModifier = self
end

function modifier_sniper_rangefinder:OnRefresh()
    self.bonus_range = self:GetSpecialValueFor("bonus_range")
    self.bonus_bat = self:GetSpecialValueFor("bonus_attack_time")
    self.bonus_attack_speed = self:GetSpecialValueFor("bonus_attack_speed")
	
end

function modifier_sniper_rangefinder:DeclareFunctions()
    return {MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
			MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
			MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,}
end

function modifier_sniper_rangefinder:GetModifierAttackRangeBonus()
	if self.bonus_range <= 0 then return end
	if self:GetCaster():PassivesDisabled() then return end
    return self.bonus_range
end

function modifier_sniper_rangefinder:GetModifierAttackRangeBonus()
	if self.bonus_bat <= 0 then return end
	if self:GetCaster():PassivesDisabled() then return end
    return self.bonus_bat
end

function modifier_sniper_rangefinder:GetModifierAttackSpeedBonus_Constant()
	if self.bonus_bat <= 0 then return end
	if self:GetCaster():PassivesDisabled() then return end
    return self.bonus_attack_speed
end

function modifier_sniper_rangefinder:GetModifierOverrideAbilitySpecial( params )
	if self._inquiringLevelSpecialValue then return end
	if params.ability_special_value == "bonus_attack_speed" then
		return 1
	end
end

function modifier_sniper_rangefinder:GetModifierOverrideAbilitySpecialValue( params )
	if self._inquiringLevelSpecialValue then return end
	local specialValue = params.ability_special_value
	if params.ability_special_value == "bonus_attack_speed" and self.bonus_attack_speed_level then
		self._inquiringLevelSpecialValue = true
		local flBaseValue = params.ability:GetLevelSpecialValueFor( specialValue, params.ability_special_level )
		self._inquiringLevelSpecialValue = false
		if flBaseValue > 0 then
			return flBaseValue + (params.ability:GetCaster():GetLevel() - 1) * self.bonus_attack_speed_level
		end
	end
end
item_headchopper = class({})
function item_headchopper:GetIntrinsicModifierName()
	return "modifier_item_headchopper_handle"
end

modifier_item_headchopper_handle = class(itemBaseClass)
LinkLuaModifier( "modifier_item_headchopper_handle", "items/item_headchopper.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_item_headchopper_handle:OnCreated()
	self.crit_damage = self:GetSpecialValueFor("critical_damage")
	self.crit_chance = self:GetSpecialValueFor("critical_chance")
	
	self.strength = self:GetSpecialValueFor("bonus_strength")
	self.damage = self:GetSpecialValueFor("bonus_damage")
end

function modifier_item_headchopper_handle:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_headchopper_handle:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE
			}
end

function modifier_item_headchopper_handle:GetModifierBonusStats_Strength()
	return self.strength
end

function modifier_item_headchopper_handle:GetModifierBaseAttack_BonusDamage()
	return self.damage
end

function modifier_item_headchopper_handle:GetModifierPreAttack_CriticalStrike(params)
	if RollPercentage( self.crit_chance ) then
		params.target:DisableHealing(self:GetSpecialValueFor("curse_duration"))
		return self.crit_damage
	end
end

function modifier_item_headchopper_handle:IsHidden()
	return true
end

function modifier_item_headchopper_handle:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
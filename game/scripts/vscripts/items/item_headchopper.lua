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
	
	self.effect_damage = self:GetSpecialValueFor("effect_bonus_damage")
end

function modifier_item_headchopper_handle:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_headchopper_handle:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
			MODIFIER_EVENT_ON_ATTACK_START,
			MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_item_headchopper_handle:OnAttackStart(params)
	if params.attacker == self:GetParent() then
		if self.effect_modifier and not self.effect_modifier:IsNull() then
			self.effect_modifier:Destroy()
		end
	end
end

function modifier_item_headchopper_handle:OnAttackLanded(params)
	if params.attacker == self:GetParent() then
		if self.effect_modifier and not self.effect_modifier:IsNull() then
			self.effect_modifier:Destroy()
		else
			self.effect_modifier = nil
		end
	end
end

function modifier_item_headchopper_handle:GetModifierTotalDamageOutgoing_Percentage(params)
	if params.target:IsHealingDisabled() then
		return self.effect_damage
	end
end


function modifier_item_headchopper_handle:GetModifierBonusStats_Strength()
	return self.strength
end

function modifier_item_headchopper_handle:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function modifier_item_headchopper_handle:GetModifierPreAttack_CriticalStrike(params)
	if self:RollPRNG( self.crit_chance ) then
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
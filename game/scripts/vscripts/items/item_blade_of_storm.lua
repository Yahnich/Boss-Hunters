item_blade_of_storm = class({})

LinkLuaModifier( "modifier_item_blade_of_storm", "items/item_blade_of_storm.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_blade_of_storm:GetIntrinsicModifierName()
	return "modifier_item_blade_of_storm"
end

modifier_item_blade_of_storm = class({})

function modifier_item_blade_of_storm:OnCreated()
	self.attackSpeed = self:GetSpecialValueFor("bonus_attackspeed")
	self.evasion = self:GetSpecialValueFor("bonus_evasion")
	self.agility = self:GetSpecialValueFor("bonus_agility")
	self.bonusDamage = self:GetSpecialValueFor("bonus_damage")
	self.movespeed = self:GetSpecialValueFor("bonus_movespeed")
	
	self.shockDamage = self:GetSpecialValueFor("shock_damage")
	self.shockChance = self:GetSpecialValueFor("shock_chance")
	self.shockDuration = self:GetSpecialValueFor("shock_duration")
end

function modifier_item_blade_of_storm:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,
			
			MODIFIER_PROPERTY_EVASION_CONSTANT,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
			}
end

function modifier_item_blade_of_storm:GetModifierMoveSpeedBonus_Percentage()
	return self.movespeed
end

function modifier_item_blade_of_storm:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() and RollPercentage(self.shockChance) then
			self:GetAbility():DealDamage(self:GetParent(), params.target, self.shockDamage, {damage_type = DAMAGE_TYPE_PURE})
			params.target:Paralyze(self:GetAbility(), self:GetCaster(), self.shockDuration)
		end
	end
end

function modifier_item_blade_of_storm:GetModifierAttackSpeedBonus()
	return self.attackSpeed
end

function modifier_item_blade_of_storm:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_item_blade_of_storm:GetModifierPreAttack_BonusDamage()
	return self.bonusDamage
end

function modifier_item_blade_of_storm:GetModifierBonusStats_Agility()
	return self.agility
end

function modifier_item_blade_of_storm:IsHidden()
	return true
end

function modifier_item_blade_of_storm:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
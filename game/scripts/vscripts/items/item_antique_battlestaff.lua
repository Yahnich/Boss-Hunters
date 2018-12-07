item_antique_battlestaff = class({})

LinkLuaModifier( "modifier_item_antique_battlestaff", "items/item_antique_battlestaff.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_antique_battlestaff:GetIntrinsicModifierName()
	return "modifier_item_antique_battlestaff"
end

modifier_item_antique_battlestaff = class({})

function modifier_item_antique_battlestaff:OnCreated()
	self.chance = self:GetSpecialValueFor("pierce_chance")
	self.damage = self:GetSpecialValueFor("pierce_damage")
	
	self.bonus_damage = self:GetSpecialValueFor("bonus_damage")
	self.bonus_agility = self:GetSpecialValueFor("bonus_agility")
	self.bonus_attack_speed = self:GetSpecialValueFor("bonus_attack_speed")
	self.bonus_move_speed = self:GetSpecialValueFor("bonus_move_speed")
end

function modifier_item_antique_battlestaff:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,}
end

function modifier_item_antique_battlestaff:GetAccuracy()
	self.miss = self:RollPRNG(self.chance)
	if self.miss then
		return 100
	end
end

function modifier_item_antique_battlestaff:OnAttackLanded(params)
	if params.attacker == self:GetParent() and self.miss then
		self.miss = false
		self:GetAbility():DealDamage(params.attacker, params.target, self.damage, {damage_type = DAMAGE_TYPE_MAGICAL})
	end
end

function modifier_item_antique_battlestaff:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end

function modifier_item_antique_battlestaff:GetModifierBonusStats_Agility()
	return self.bonus_agility
end

function modifier_item_antique_battlestaff:GetModifierAttackSpeedBonus()
	return self.bonus_attack_speed
end

function modifier_item_antique_battlestaff:GetModifierMoveSpeedBonus_Percentage()
	return self.bonus_move_speed
end

function modifier_item_antique_battlestaff:IsHidden()
	return true
end

function modifier_item_antique_battlestaff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

item_visionarys_cutlass = class({})

LinkLuaModifier( "modifier_item_visionarys_cutlass", "items/item_visionarys_cutlass.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_visionarys_cutlass:GetIntrinsicModifierName()
	return "modifier_item_visionarys_cutlass"
end

modifier_item_visionarys_cutlass = class(class(itemBaseClass))

function modifier_item_visionarys_cutlass:OnCreated()
	self.chance = self:GetSpecialValueFor("pierce_chance")
	self.damage = self:GetSpecialValueFor("pierce_damage")
	
	self.bonus_attack_speed = self:GetSpecialValueFor("bonus_attack_speed")
	self.bonus_damage = self:GetSpecialValueFor("bonus_damage")
end

function modifier_item_visionarys_cutlass:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_item_visionarys_cutlass:GetAccuracy(bInfo)
	if not bInfo then
		self.miss = self:RollPRNG(self.chance)
		if self.miss then
			return 100
		end
	else
		return self.chance
	end
end

function modifier_item_visionarys_cutlass:OnAttackLanded(params)
	if params.attacker == self:GetParent() and self.miss then
		self.miss = false
		self:GetAbility():DealDamage(params.attacker, params.target, self.damage, {damage_type = DAMAGE_TYPE_MAGICAL})
	end
end

function modifier_item_visionarys_cutlass:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end

function modifier_item_antique_battlestaff:GetModifierAttackSpeedBonus()
	return self.bonus_attack_speed
end
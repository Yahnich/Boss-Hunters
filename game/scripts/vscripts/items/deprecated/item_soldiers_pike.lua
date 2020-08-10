item_soldiers_pike = class({})

LinkLuaModifier( "modifier_item_soldiers_pike", "items/item_soldiers_pike.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_soldiers_pike:GetIntrinsicModifierName()
	return "modifier_item_soldiers_pike"
end

modifier_item_soldiers_pike = class(itemBaseClass)

function modifier_item_soldiers_pike:OnCreated()
	self.range = self:GetSpecialValueFor("bonus_range")
	self.damage = self:GetSpecialValueFor("damage")
	self.chance = self:GetSpecialValueFor("chance")
end

function modifier_item_soldiers_pike:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_ATTACK_RANGE_BONUS}
end

function modifier_item_soldiers_pike:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() and RollPercentage(self.chance) then
			self:GetAbility():DealDamage(self:GetParent(), params.target, self.damage, {damage_type = DAMAGE_TYPE_PURE}, OVERHEAD_ALERT_DAMAGE)
		end
	end
end

function modifier_item_soldiers_pike:GetModifierAttackRangeBonus()
	if self:GetParent():IsRangedAttacker() then
		return self.range
	end
end
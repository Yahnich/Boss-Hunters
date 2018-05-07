item_lance_of_longinus = class({})

LinkLuaModifier( "modifier_item_lance_of_longinus", "items/item_lance_of_longinus.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_lance_of_longinus:GetIntrinsicModifierName()
	return "modifier_item_lance_of_longinus"
end

modifier_item_lance_of_longinus = class({})

function modifier_item_lance_of_longinus:OnCreated()
	self.range = self:GetSpecialValueFor("bonus_attack_range")
	self.damage = self:GetSpecialValueFor("pierce_damage") / 100
	self.chance = self:GetSpecialValueFor("pierce_chance")
end

function modifier_item_lance_of_longinus:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_ATTACK_RANGE_BONUS}
end

function modifier_item_lance_of_longinus:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() and RollPercentage(self.chance) then
			self:GetAbility():DealDamage(self:GetParent(), params.target, self.damage * self:GetParent():GetAttackDamage(), {damage_type = DAMAGE_TYPE_PURE}, OVERHEAD_ALERT_DAMAGE)
		end
	end
end

function modifier_item_lance_of_longinus:GetModifierAttackRangeBonus()
	return self.range
end


function modifier_item_lance_of_longinus:IsHidden()
	return true
end

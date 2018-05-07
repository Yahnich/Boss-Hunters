item_siegebreaker = class({})

LinkLuaModifier( "modifier_item_siegebreaker", "items/item_siegebreaker.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_siegebreaker:GetIntrinsicModifierName()
	return "modifier_item_siegebreaker"
end

modifier_item_siegebreaker = class({})

function modifier_item_siegebreaker:OnCreated()
	self.range = self:GetSpecialValueFor("bonus_range")
	self.damage = self:GetSpecialValueFor("pierce_damage") / 100
	self.chance = self:GetSpecialValueFor("pierce_chance")
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_item_siegebreaker:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_ATTACK_RANGE_BONUS}
end

function modifier_item_siegebreaker:OnAttackLanded(params)
	if IsServer() then
		if self:GetParent():IsRangedAttacker() and params.attacker == self:GetParent() and RollPercentage(self.chance) then
			for _, enemy in ipairs( params.attacker:FindEnemyUnitsInRadius( params.target:GetAbsOrigin(), self.radius ) ) do
				self:GetAbility():DealDamage(self:GetParent(), enemy, self.damage * params.original_damage, {damage_type = DAMAGE_TYPE_PURE}, OVERHEAD_ALERT_DAMAGE)
			end
		end
	end
end

function modifier_item_siegebreaker:GetModifierAttackRangeBonus()
	if self:GetParent():IsRangedAttacker() then
		return self.range
	end
end


function modifier_item_siegebreaker:IsHidden()
	return true
end

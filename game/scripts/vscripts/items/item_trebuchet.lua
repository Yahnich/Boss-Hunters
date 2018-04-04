item_trebuchet = class({})

LinkLuaModifier( "modifier_item_trebuchet", "items/item_trebuchet.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_trebuchet:GetIntrinsicModifierName()
	return "modifier_item_trebuchet"
end

modifier_item_trebuchet = class({})

function modifier_item_trebuchet:OnCreated()
	self.range = self:GetSpecialValueFor("bonus_range")
	self.damage = self:GetSpecialValueFor("pierce_damage") / 100
	self.chance = self:GetSpecialValueFor("pierce_chance")
	self.radius = self:GetSpecialValueFor("radius")
	
	self.stat = self:GetSpecialValueFor("bonus_all")
end

function modifier_item_trebuchet:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS}
end

function modifier_item_trebuchet:GetModifierBonusStats_Strength()
	return self.stat
end

function modifier_item_trebuchet:GetModifierBonusStats_Agility()
	return self.stat
end

function modifier_item_trebuchet:GetModifierBonusStats_Intellect()
	return self.stat
end

function modifier_item_trebuchet:OnAttackLanded(params)
	if IsServer() then
		if self:GetParent():IsRangedAttacker() and params.attacker == self:GetParent() and RollPercentage(self.chance) then
			for _, enemy in ipairs( params.attacker:FindEnemyUnitsInRadius( params.target:GetAbsOrigin(), self.radius ) ) do
				self:GetAbility():DealDamage(self:GetParent(), enemy, self.damage * params.original_damage, {damage_type = DAMAGE_TYPE_PURE})
			end
		end
	end
end

function modifier_item_trebuchet:GetModifierAttackRangeBonus()
	if self:GetParent():IsRangedAttacker() then
		return self.range
	end
end

function modifier_item_trebuchet:IsHidden()
	return true
end

function modifier_item_trebuchet:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

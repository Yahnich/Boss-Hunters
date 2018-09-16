item_iron_rod = class({})

LinkLuaModifier( "modifier_item_iron_rod", "items/item_iron_rod.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_iron_rod:GetIntrinsicModifierName()
	return "modifier_item_iron_rod"
end

modifier_item_iron_rod = class(itemBaseClass)

function modifier_item_iron_rod:OnCreated()
	self.chance = self:GetSpecialValueFor("pierce_chance")
	self.damage = self:GetSpecialValueFor("pierce_damage")
end

function modifier_item_iron_rod:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_item_iron_rod:OnAttackLanded(params)
	if params.attacker == self:GetParent() and self:RollPRNG(self.chance) then
		self:GetAbility():DealDamage(params.attacker, params.target, self.damage, {damage_type = DAMAGE_TYPE_MAGICAL})
	end
end

function modifier_item_iron_rod:IsHidden()
	return true
end

function modifier_item_iron_rod:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

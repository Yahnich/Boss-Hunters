item_amulet_of_aggression = class({})
LinkLuaModifier( "modifier_item_amulet_of_aggression_passive", "items/item_amulet_of_aggression.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_amulet_of_aggression:GetIntrinsicModifierName()
	return "modifier_item_amulet_of_aggression_passive"
end

modifier_item_amulet_of_aggression_passive = class({})

function modifier_item_amulet_of_aggression_passive:OnCreated()
	self.bonusThreat = self:GetSpecialValueFor("bonus_threat")
end

function modifier_item_amulet_of_aggression_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_item_amulet_of_aggression_passive:Bonus_ThreatGain()
	return self.bonusThreat
end

function modifier_item_amulet_of_aggression_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_amulet_of_aggression_passive:IsHidden()
	return true
end
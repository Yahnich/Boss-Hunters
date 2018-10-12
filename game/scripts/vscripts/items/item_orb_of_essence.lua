item_orb_of_essence = class({})

function item_orb_of_essence:GetIntrinsicModifierName()
	return "modifier_item_orb_of_essence"
end

modifier_item_orb_of_essence = class(itemBaseClass)
LinkLuaModifier( "modifier_item_orb_of_essence", "items/item_orb_of_essence.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_item_orb_of_essence:OnCreated()
	self.mr = self:GetSpecialValueFor("bonus_mana_regen")
	self.intellect = self:GetSpecialValueFor("bonus_intellect")
end

function modifier_item_orb_of_essence:DeclareFunctions()
	return {MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			}
end

function modifier_item_orb_of_essence:GetModifierConstantManaRegen()
	return self.mr
end

function modifier_item_orb_of_essence:GetModifierBonusStats_Intellect()
	return self.intellect
end
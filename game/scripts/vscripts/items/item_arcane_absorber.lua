item_arcane_absorber = class({})
LinkLuaModifier( "modifier_item_arcane_absorber_passive", "items/item_arcane_absorber.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_arcane_absorber:GetIntrinsicModifierName()
	return "modifier_item_arcane_absorber_passive"
end

function item_arcane_absorber:GetRuneSlots()
	return self:GetSpecialValueFor("rune_slots")
end

item_arcane_absorber_2 = class(item_arcane_absorber)
item_arcane_absorber_3 = class(item_arcane_absorber)
item_arcane_absorber_4 = class(item_arcane_absorber)
item_arcane_absorber_5 = class(item_arcane_absorber)
item_arcane_absorber_6 = class(item_arcane_absorber)
item_arcane_absorber_7 = class(item_arcane_absorber)
item_arcane_absorber_8 = class(item_arcane_absorber)
item_arcane_absorber_9 = class(item_arcane_absorber)

modifier_item_arcane_absorber_passive = class(itemBasicBaseClass)

function modifier_item_arcane_absorber_passive:OnCreatedSpecific()
	self:OnRefreshSpecific()
end

function modifier_item_arcane_absorber_passive:OnRefreshSpecific()
	self.status_amp = self:GetSpecialValueFor("status_amp")
	self.status_resist = self:GetSpecialValueFor("status_resist")
end

function modifier_item_arcane_absorber_passive:DeclareFunctions()
	local funcs = self:GetDefaultFunctions()
	table.insert( funcs, MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING )
	return funcs
end

function modifier_item_arcane_absorber_passive:GetModifierStatusResistanceStacking(params)
	return self.status_resist
end

function modifier_item_arcane_absorber_passive:GetModifierStatusAmplify_Percentage(params)
	return self.status_amp
end
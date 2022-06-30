item_fortress_shield = class({})

function item_fortress_shield:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_item_fortress_shield_block", {})
end

function item_fortress_shield:GetIntrinsicModifierName()
	return "modifier_item_fortress_shield_passive"
end

item_fortress_shield_2 = class(item_fortress_shield)
item_fortress_shield_3 = class(item_fortress_shield)
item_fortress_shield_4 = class(item_fortress_shield)
item_fortress_shield_5 = class(item_fortress_shield)
item_fortress_shield_6 = class(item_fortress_shield)
item_fortress_shield_7 = class(item_fortress_shield)
item_fortress_shield_8 = class(item_fortress_shield)
item_fortress_shield_9 = class(item_fortress_shield)

modifier_item_fortress_shield_passive = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_fortress_shield_passive", "items/item_fortress_shield.lua" ,LUA_MODIFIER_MOTION_NONE )

modifier_item_fortress_shield_block = class({})
LinkLuaModifier( "modifier_item_fortress_shield_block", "items/item_fortress_shield.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_fortress_shield_block:OnCreated()
	self:OnRefresh()
end

function modifier_item_fortress_shield_block:OnRefresh()
	self.block = self:GetSpecialValueFor("damage_reduction") * (-1)
	self.linger_duration = self:GetSpecialValueFor("linger_duration")
end

function modifier_item_fortress_shield_block:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE}
end

function modifier_item_fortress_shield_block:GetModifierIncomingDamage_Percentage()
	if self:GetDuration() < 0 then self:SetDuration( self.linger_duration, true ) end
	return self.block
end
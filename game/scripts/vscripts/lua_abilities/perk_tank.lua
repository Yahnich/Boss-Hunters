perk_tank = class({})

LinkLuaModifier( "modifier_perk_tank", "lua_abilities/heroes/modifiers/modifier_perk_tank.lua" ,LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function perk_tank:GetIntrinsicModifierName()
	return "modifier_perk_tank"
end

function perk_tank:OnUpgrade()
	self:GetCaster():RemoveModifierByName("modifier_perk_tank")
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_perk_tank", nil)
end

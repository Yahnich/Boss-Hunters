enchantress_siegebreaker = class({})

LinkLuaModifier( "modifier_enchantress_siegebreaker", "lua_abilities/heroes/modifiers/enchantress_siegebreaker.lua" ,LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function enchantress_siegebreaker:OnSpellStart()
	if not self:GetCaster():HasModifier("modifier_enchantress_siegebreaker") then
		self.on = true
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_enchantress_siegebreaker", {})
	else
		self:GetCaster():RemoveModifierByName("modifier_enchantress_siegebreaker")
		self.on = false
	end
end

function enchantress_siegebreaker:OnUpgrade()
	self:GetCaster():RemoveModifierByName("modifier_enchantress_siegebreaker")
	if self.on then
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_enchantress_siegebreaker", {})
	end
end

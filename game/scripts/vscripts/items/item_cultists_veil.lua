item_cultists_veil = class({})

LinkLuaModifier( "modifier_item_cultists_veil", "items/item_cultists_veil.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_cultists_veil:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	return "modifier_item_cultists_veil"
end

LinkLuaModifier( "modifier_cultists_veil_debuff", "items/item_cultists_veil.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_cultists_veil_debuff = class({})

function modifier_cultists_veil_debuff:OnCreated()
	self.mr = (-1) * self:GetAbility():GetSpecialValueFor("bonus_magic_damage")
end

function modifier_cultists_veil_debuff:OnRefresh()
	self.mr = math.min(self.mr, (-1) * self:GetAbility():GetSpecialValueFor("bonus_magic_damage"))
end

function modifier_cultists_veil_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_cultists_veil_debuff:GetModifierMagicalResistanceBonus()
	return self.mr
end
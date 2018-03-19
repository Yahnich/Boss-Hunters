item_wings_of_icarus = class({})

function item_wings_of_icarus:GetIntrinsicModifierName()
	return "modifier_item_wings_of_icarus_passive"
end

function item_wings_of_icarus:OnSpellStart()
	local caster = self:GetCaster()
	caster:AddNewModifier(caster, self, "modifier_item_wings_of_icarus_active", {duration = self:GetTalentSpecialValueFor("duration")})
end

modifier_item_wings_of_icarus_passive = class({})
LinkLuaModifier( "modifier_item_wings_of_icarus_passive", "items/item_wings_of_icarus.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_wings_of_icarus_passive:OnCreated()
	self.bonus_ms = self:GetSpecialValueFor("bonus_ms")
end

function modifier_item_wings_of_icarus_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_UNIQUE}
end

function modifier_item_wings_of_icarus_passive:GetModifierMoveSpeedBonus_Special_Boots()
	return self.bonus_ms
end

function modifier_item_wings_of_icarus_passive:IsHidden()
	return true
end

modifier_item_wings_of_icarus_active = class({})
LinkLuaModifier( "modifier_item_wings_of_icarus_active", "items/item_wings_of_icarus.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_wings_of_icarus_active:OnCreated()
	self.bonus_ms = self:GetSpecialValueFor("active_ms")
end

function modifier_item_wings_of_icarus_active:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
			MODIFIER_PROPERTY_MOVESPEED_LIMIT,
			MODIFIER_PROPERTY_MOVESPEED_MAX}
end

function modifier_item_wings_of_icarus_active:GetModifierMoveSpeed_AbsoluteMin()
	return self.bonus_ms
end

function modifier_item_wings_of_icarus_active:GetModifierMoveSpeed_Limit()
	return self.bonus_ms
end

function modifier_item_wings_of_icarus_active:GetModifierMoveSpeed_Max()
	return self.bonus_ms
end

function modifier_item_wings_of_icarus_active:IsHidden()
	return true
end
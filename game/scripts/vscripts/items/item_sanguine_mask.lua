item_sanguine_mask = class({})
LinkLuaModifier( "modifier_item_sanguine_mask_passive", "items/item_sanguine_mask.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_sanguine_mask:GetIntrinsicModifierName()
	return "modifier_item_sanguine_mask_passive"
end

item_sanguine_mask_2 = class(item_sanguine_mask)
item_sanguine_mask_3 = class(item_sanguine_mask)
item_sanguine_mask_4 = class(item_sanguine_mask)
item_sanguine_mask_5 = class(item_sanguine_mask)
item_sanguine_mask_6 = class(item_sanguine_mask)
item_sanguine_mask_7 = class(item_sanguine_mask)
item_sanguine_mask_8 = class(item_sanguine_mask)
item_sanguine_mask_9 = class(item_sanguine_mask)

modifier_item_sanguine_mask_passive = class(itemBasicBaseClass)

function modifier_item_sanguine_mask_passive:OnCreatedSpecific()
	self.lifesteal = self:GetSpecialValueFor("lifesteal")
	self.mLifesteal = self:GetSpecialValueFor("mob_divider") / 100
	if IsServer() then
		self:GetCaster():HookInModifier( "GetModifierLifestealBonus", self )
	end
end

function modifier_item_sanguine_mask_passive:OnRefreshSpecific()
	self.lifesteal = self:GetSpecialValueFor("lifesteal")
	self.mLifesteal = self:GetSpecialValueFor("mob_divider") / 100
	if IsServer() then
		self:GetCaster():HookInModifier( "GetModifierLifestealBonus", self )
	end
end

function modifier_item_sanguine_mask_passive:OnDestroySpecific()
	if IsServer() then
		self:GetCaster():HookOutModifier( "GetModifierLifestealBonus", self )
	end
end

function modifier_item_sanguine_mask_passive:GetModifierLifestealBonus(params)
	local lifesteal = self.lifesteal
	if params.inflictor then
		if params.unit:IsMinion() then
			lifesteal = lifesteal * self.mLifesteal
		end
	end
	return lifesteal
end
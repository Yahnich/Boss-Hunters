item_dark_lord_headdress = class({})

function item_dark_lord_headdress:GetIntrinsicModifierName()
	return "modifier_item_dark_lord_headdress"
end

item_dark_lord_headdress_2 = class(item_dark_lord_headdress)
item_dark_lord_headdress_3 = class(item_dark_lord_headdress)
item_dark_lord_headdress_4 = class(item_dark_lord_headdress)
item_dark_lord_headdress_5 = class(item_dark_lord_headdress)
item_dark_lord_headdress_6 = class(item_dark_lord_headdress)
item_dark_lord_headdress_7 = class(item_dark_lord_headdress)
item_dark_lord_headdress_8 = class(item_dark_lord_headdress)
item_dark_lord_headdress_9 = class(item_dark_lord_headdress)

modifier_item_dark_lord_headdress = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_dark_lord_headdress", "items/item_dark_lord_headdress.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_dark_lord_headdress:OnCreatedSpecific()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_item_dark_lord_headdress:OnRefreshSpecific()
	self.radius = self:GetSpecialValueFor("radius")
end

function modifier_item_dark_lord_headdress:IsAura()
	return true
end

function modifier_item_dark_lord_headdress:GetModifierAura()
	return "modifier_item_dark_lord_headdress_aura_"..self:GetAbility():GetItemSlot()
end

function modifier_item_dark_lord_headdress:GetAuraRadius()
	return self.radius
end

function modifier_item_dark_lord_headdress:GetAuraDuration()
	return 0.5
end

function modifier_item_dark_lord_headdress:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_dark_lord_headdress:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_item_dark_lord_headdress:GetAuraSearchFlags()    
	return DOTA_UNIT_TARGET_FLAG_NONE
end

LinkLuaModifier( "modifier_item_dark_lord_headdress_aura", "items/item_dark_lord_headdress.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_dark_lord_headdress_aura = class(itemAuraBaseClass)

function modifier_item_dark_lord_headdress_aura:GetStoneShareability()
	return self.stone_share
end

function modifier_item_dark_lord_headdress_aura:OnCreatedSpecific()
	self.lifesteal = self:GetSpecialValueFor("lifesteal")
	self.stone_share = self:GetSpecialValueFor("stone_share")
	self.mLifesteal = self:GetSpecialValueFor("mob_divider") / 100
	if IsServer() then
		self:GetParent():HookInModifier( "GetModifierLifestealBonus", self )
		self:SetupRuneSystem(self.stone_share)
		self:SetHasCustomTransmitterData( true )
	end
end

function modifier_item_dark_lord_headdress_aura:OnRefreshSpecific()
	self.lifesteal = self:GetSpecialValueFor("lifesteal")
	self.stone_share = self:GetSpecialValueFor("stone_share")
	self.mLifesteal = self:GetSpecialValueFor("mob_divider") / 100
	if IsServer() then
		self:GetParent():HookInModifier( "GetModifierLifestealBonus", self )
	end
end

function modifier_item_dark_lord_headdress_aura:OnDestroySpecific()
	if IsServer() then
		self:GetParent():HookOutModifier( "GetModifierLifestealBonus", self )
	end
end

function modifier_item_dark_lord_headdress_aura:GetModifierLifestealBonus(params)
	local lifesteal = self.lifesteal
	if params.inflictor then
		if params.unit:IsMinion() then
			lifesteal = lifesteal * self.mLifesteal
		end
	end
	return lifesteal
end

modifier_item_dark_lord_headdress_aura_0 = class(modifier_item_dark_lord_headdress_aura)
LinkLuaModifier( "modifier_item_dark_lord_headdress_aura_0", "items/item_dark_lord_headdress.lua" ,LUA_MODIFIER_MOTION_NONE )

modifier_item_dark_lord_headdress_aura_1 = class(modifier_item_dark_lord_headdress_aura)
LinkLuaModifier( "modifier_item_dark_lord_headdress_aura_1", "items/item_dark_lord_headdress.lua" ,LUA_MODIFIER_MOTION_NONE )

modifier_item_dark_lord_headdress_aura_2 = class(modifier_item_dark_lord_headdress_aura)
LinkLuaModifier( "modifier_item_dark_lord_headdress_aura_2", "items/item_dark_lord_headdress.lua" ,LUA_MODIFIER_MOTION_NONE )

modifier_item_dark_lord_headdress_aura_3 = class(modifier_item_dark_lord_headdress_aura)
LinkLuaModifier( "modifier_item_dark_lord_headdress_aura_3", "items/item_dark_lord_headdress.lua" ,LUA_MODIFIER_MOTION_NONE )

modifier_item_dark_lord_headdress_aura_4 = class(modifier_item_dark_lord_headdress_aura)
LinkLuaModifier( "modifier_item_dark_lord_headdress_aura_4", "items/item_dark_lord_headdress.lua" ,LUA_MODIFIER_MOTION_NONE )

modifier_item_dark_lord_headdress_aura_5 = class(modifier_item_dark_lord_headdress_aura)
LinkLuaModifier( "modifier_item_dark_lord_headdress_aura_5", "items/item_dark_lord_headdress.lua" ,LUA_MODIFIER_MOTION_NONE )
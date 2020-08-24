item_berserkers_mask = class({})


function item_berserkers_mask:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_berserkers_mask_active", {duration = self:GetSpecialValueFor("duration")})
	EmitSoundOn( "DOTA_Item.MaskOfMadness.Activate", self:GetCaster() )
end

function item_berserkers_mask:GetIntrinsicModifierName()
	return "modifier_item_berserkers_mask"
end

item_berserkers_mask_2 = class(item_berserkers_mask)
item_berserkers_mask_3 = class(item_berserkers_mask)
item_berserkers_mask_4 = class(item_berserkers_mask)
item_berserkers_mask_5 = class(item_berserkers_mask)
item_berserkers_mask_6 = class(item_berserkers_mask)
item_berserkers_mask_7 = class(item_berserkers_mask)
item_berserkers_mask_8 = class(item_berserkers_mask)
item_berserkers_mask_9 = class(item_berserkers_mask)

modifier_item_berserkers_mask = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_berserkers_mask", "items/item_berserkers_mask.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_berserkers_mask:OnCreatedSpecific()
	self.lifesteal = self:GetSpecialValueFor("lifesteal")
	self.mLifesteal = self:GetSpecialValueFor("mob_divider") / 100
	if IsServer() then
		self:GetCaster():HookInModifier( "GetModifierLifestealBonus", self )
	end
end

function modifier_item_berserkers_mask:OnRefreshSpecific()
	self.lifesteal = self:GetSpecialValueFor("lifesteal")
	self.mLifesteal = self:GetSpecialValueFor("mob_divider") / 100
	if IsServer() then
		self:GetCaster():HookInModifier( "GetModifierLifestealBonus", self )
	end
end

function modifier_item_berserkers_mask:OnDestroySpecific()
	if IsServer() then
		self:GetCaster():HookOutModifier( "GetModifierLifestealBonus", self )
	end
end

function modifier_item_berserkers_mask:GetModifierLifestealBonus(params)
	local lifesteal = self.lifesteal
	if params.inflictor then
		if params.unit:IsMinion() then
			lifesteal = lifesteal * self.mLifesteal
		end
	end
	return lifesteal
end

LinkLuaModifier( "modifier_item_berserkers_mask_active", "items/item_berserkers_mask.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_item_berserkers_mask_active = class({})

function modifier_item_berserkers_mask_active:OnCreated()
	self.lifesteal = self:GetSpecialValueFor("active_lifesteal")
	self.as = self:GetSpecialValueFor("attackspeed")
	self.ms = self:GetSpecialValueFor("movespeed")
	self.armor = self:GetSpecialValueFor("armor_reduction")
	if IsServer() then
		self:GetCaster():HookInModifier( "GetModifierLifestealBonus", self )
	end
end

function modifier_item_berserkers_mask_active:OnRefresh()
	self.lifesteal = self:GetSpecialValueFor("active_lifesteal")
	self.as = self:GetSpecialValueFor("attackspeed")
	self.ms = self:GetSpecialValueFor("movespeed")
	self.armor = self:GetSpecialValueFor("armor_reduction")
	if IsServer() then
		self:GetCaster():HookInModifier( "GetModifierLifestealBonus", self )
	end
end

function modifier_item_berserkers_mask_active:OnDestroy()
	if IsServer() then
		self:GetCaster():HookOutModifier( "GetModifierLifestealBonus", self )
	end
end

function modifier_item_berserkers_mask_active:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT, MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end

function modifier_item_berserkers_mask_active:CheckState()
	return {[MODIFIER_STATE_SILENCED] = true}
end

function modifier_item_berserkers_mask_active:GetModifierLifestealBonus(params)
	if params.attacker == self:GetParent() and ( params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_PROPERTY_FIRE) ) then
		return self.lifesteal
	end
end

function modifier_item_berserkers_mask_active:GetModifierAttackSpeedBonus()
	return self.as
end

function modifier_item_berserkers_mask_active:GetModifierMoveSpeedBonus_Constant()
	return self.ms
end

function modifier_item_berserkers_mask_active:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_item_berserkers_mask_active:GetEffectName()
	return "particles/items2_fx/mask_of_madness.vpcf"
end

function modifier_item_berserkers_mask_active:GetStatusEffectName()
	return "particles/status_fx/status_effect_beserkers_call.vpcf"
end

function modifier_item_berserkers_mask_active:StatusEffectPriority()
	return 5
end
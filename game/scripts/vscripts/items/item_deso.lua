item_desolator2 = class({})
LinkLuaModifier( "modifier_item_deso_handle", "items/item_deso.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_deso", "items/item_deso.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_desolator2:GetIntrinsicModifierName()
	return "modifier_item_deso_handle"
end

item_desolator3 = class({item_desolator2})
function item_desolator3:GetIntrinsicModifierName()
	return "modifier_item_deso_handle"
end

item_desolator4 = class({item_desolator2})
function item_desolator4:GetIntrinsicModifierName()
	return "modifier_item_deso_handle"
end

item_desolator5 = class({item_desolator2})
function item_desolator5:GetIntrinsicModifierName()
	return "modifier_item_deso_handle"
end

modifier_item_deso_handle = class({})
function modifier_item_deso_handle:OnCreated(table)
	self.bonus_damage = self:GetSpecialValueFor("bonus_damage")
end

function modifier_item_deso_handle:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_deso_handle:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_item_deso_handle:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end

function modifier_item_deso_handle:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_item_deso", {Duration = self:GetAbility():GetSpecialValueFor("duration")})
		end
	end
end

function modifier_item_deso_handle:IsHidden()
	return true
end

modifier_item_deso = class({})
function modifier_item_deso:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_item_deso:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("armor_reduction")
end
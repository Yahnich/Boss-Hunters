item_thanatos = class({})

LinkLuaModifier( "modifier_item_thanatos", "items/item_thanatos.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_thanatos:GetIntrinsicModifierName()
	return "modifier_item_thanatos"
end

modifier_item_thanatos = class({})
function modifier_item_thanatos:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_item_thanatos:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_thanatos:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_thanatos_debuff", {Duration = self:GetAbility():GetSpecialValueFor("base_duration")})
			params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_thanatos_stacking_debuff", {Duration = self:GetAbility():GetSpecialValueFor("stack_duration")})
		end
	end
end

function modifier_item_thanatos:IsHidden()
	return true
end

function modifier_item_thanatos:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

LinkLuaModifier( "modifier_thanatos_debuff", "items/item_thanatos.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_thanatos_debuff = class({})

function modifier_thanatos_debuff:OnCreated()
	self.armor = self:GetAbility():GetSpecialValueFor("base_armor_reduction")
	self.stack = self:GetAbility():GetSpecialValueFor("stack_armor_reduction")
	self:SetStackCount(1)
	self:AddIndependentStack(self:GetAbility():GetSpecialValueFor("stack_duration"))
end

function modifier_thanatos_debuff:OnRefresh()
	self.armor = math.max(self.armor, self:GetAbility():GetSpecialValueFor("base_armor_reduction"))
	self.stack = self:GetAbility():GetSpecialValueFor("stack_armor_reduction")
	self:AddIndependentStack(self:GetAbility():GetSpecialValueFor("stack_duration"))
end

function modifier_thanatos_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_thanatos_debuff:GetModifierPhysicalArmorBonus()
	return self.armor + self.stack * self:GetStackCount()
end
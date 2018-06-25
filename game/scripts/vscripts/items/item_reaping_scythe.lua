item_reaping_scythe = class({})

LinkLuaModifier( "modifier_item_reaping_scythe", "items/item_reaping_scythe.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_reaping_scythe:GetIntrinsicModifierName()
	return "modifier_item_reaping_scythe"
end

modifier_item_reaping_scythe = class({})
function modifier_item_reaping_scythe:OnCreated(table)
	self.bonus_damage = self:GetSpecialValueFor("bonus_damage")
end

function modifier_item_reaping_scythe:OnRefresh()
	self.bonus_damage = math.max(self.bonus_damage, self:GetSpecialValueFor("bonus_damage"))
end

function modifier_item_reaping_scythe:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_item_reaping_scythe:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end

function modifier_item_reaping_scythe:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_reaping_scythe_debuff", {Duration = self:GetAbility():GetSpecialValueFor("duration")})
		end
	end
end

function modifier_item_reaping_scythe:IsHidden()
	return true
end

function modifier_item_reaping_scythe:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

LinkLuaModifier( "modifier_reaping_scythe_debuff", "items/item_reaping_scythe.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_reaping_scythe_debuff = class({})

function modifier_reaping_scythe_debuff:OnCreated()
	self.armor = self:GetAbility():GetSpecialValueFor("armor_reduction")
end

function modifier_reaping_scythe_debuff:OnRefresh()
	self.armor = math.max(self.armor, self:GetAbility():GetSpecialValueFor("armor_reduction"))
end

function modifier_reaping_scythe_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_reaping_scythe_debuff:GetModifierPhysicalArmorBonus()
	return self.armor
end
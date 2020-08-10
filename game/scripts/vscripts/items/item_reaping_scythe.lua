item_reaping_scythe = class({})


function item_reaping_scythe:GetIntrinsicModifierName()
	return "modifier_item_reaping_scythe"
end

item_reaping_scythe_2 = class(item_reaping_scythe)
item_reaping_scythe_3 = class(item_reaping_scythe)
item_reaping_scythe_4 = class(item_reaping_scythe)
item_reaping_scythe_5 = class(item_reaping_scythe)
item_reaping_scythe_6 = class(item_reaping_scythe)
item_reaping_scythe_7 = class(item_reaping_scythe)
item_reaping_scythe_8 = class(item_reaping_scythe)
item_reaping_scythe_9 = class(item_reaping_scythe)

modifier_item_reaping_scythe = class(itemBasicBaseClass)
LinkLuaModifier( "modifier_item_reaping_scythe", "items/item_reaping_scythe.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_item_reaping_scythe:OnCreatedSpecific()
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_item_reaping_scythe:OnRefreshSpecific()
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_item_reaping_scythe:DeclareFunctions()
	local funcs = self:GetDefaultFunctions()
	table.insert( funcs, MODIFIER_EVENT_ON_ATTACK_LANDED )
	return funcs
end

function modifier_item_reaping_scythe:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage
end

function modifier_item_reaping_scythe:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_reaping_scythe_debuff", {Duration = self.duration})
		end
	end
end

LinkLuaModifier( "modifier_reaping_scythe_debuff", "items/item_reaping_scythe.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_reaping_scythe_debuff = class({})

function modifier_reaping_scythe_debuff:OnCreated()
	if self.armor then
		self.armor = math.min( self.armor, self:GetAbility():GetSpecialValueFor("armor_reduction") )
	else
		self.armor = self:GetAbility():GetSpecialValueFor("armor_reduction")
	end
end

function modifier_reaping_scythe_debuff:OnRefresh()
	if self.armor then
		self.armor = math.min( self.armor, self:GetAbility():GetSpecialValueFor("armor_reduction") )
	else
		self.armor = self:GetAbility():GetSpecialValueFor("armor_reduction")
	end
end

function modifier_reaping_scythe_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_reaping_scythe_debuff:GetModifierPhysicalArmorBonus()
	return self.armor
end
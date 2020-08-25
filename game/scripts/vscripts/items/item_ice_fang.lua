item_ice_fang = class({})

function item_ice_fang:GetIntrinsicModifierName()
	return "modifier_ice_fang"
end

function item_ice_fang:GetAppliedModifierName()
	return "modifier_ice_fang_debuff"
end

item_ice_fang_2 = class(item_ice_fang)
item_ice_fang_3 = class(item_ice_fang)
item_ice_fang_4 = class(item_ice_fang)
item_ice_fang_5 = class(item_ice_fang)
item_ice_fang_6 = class(item_ice_fang)
item_ice_fang_7 = class(item_ice_fang)
item_ice_fang_8 = class(item_ice_fang)
item_ice_fang_9 = class(item_ice_fang)

item_winters_breath_5 = class(item_ice_fang)

function item_winters_breath_5:GetAppliedModifierName()
	return "modifier_winters_breath_debuff"
end
item_winters_breath_6 = class(item_winters_breath_5)
item_winters_breath_7 = class(item_winters_breath_5)
item_winters_breath_8 = class(item_winters_breath_5)
item_winters_breath_9 = class(item_winters_breath_5)

-------------------
-------------------
LinkLuaModifier( "modifier_ice_fang", "items/item_ice_fang.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_ice_fang = class(itemBasicBaseClass)

function modifier_ice_fang:OnCreatedSpecific()
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_ice_fang:OnRefreshSpecific()
	self.duration = self:GetSpecialValueFor("duration")
end

function modifier_ice_fang:DeclareFunctions()
	local funcs = self:GetDefaultFunctions()
	table.insert( funcs, MODIFIER_EVENT_ON_ATTACK_LANDED )
	return funcs
end

function modifier_ice_fang:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			params.target:AddNewModifier(params.attacker, self:GetAbility(), self:GetAbility():GetAppliedModifierName(), {Duration = self.duration})
		end
	end
end

modifier_ice_fang_debuff = class({})
LinkLuaModifier( "modifier_ice_fang_debuff", "items/item_ice_fang.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_ice_fang_debuff:OnCreated()
	self.slow = self:GetAbility():GetSpecialValueFor("slow")
	if IsServer() then
		self.damage = self:GetAbility():GetSpecialValueFor("base_damage")
		self:StartIntervalThink(1)
	end
end

function modifier_ice_fang_debuff:OnRefresh()
	self.slow = math.min( self.slow, self:GetAbility():GetSpecialValueFor("slow") )
	if IsServer() then
		self.damage = math.max( self.damage, self:GetAbility():GetSpecialValueFor("base_damage") )
	end
end

function modifier_ice_fang_debuff:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {damage_type = DAMAGE_TYPE_MAGICAL})
end

function modifier_ice_fang_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_ice_fang_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_ice_fang_debuff:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end

modifier_winters_breath_debuff = class(modifier_ice_fang_debuff)
LinkLuaModifier( "modifier_winters_breath_debuff", "items/item_ice_fang.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_winters_breath_debuff:GetModifierAttackSpeedBonus() return self.slow end
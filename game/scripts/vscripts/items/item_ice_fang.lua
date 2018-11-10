item_ice_fang = class({})

LinkLuaModifier( "modifier_item_ice_fang", "items/item_ice_fang.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_ice_fang:GetIntrinsicModifierName()
	return "modifier_item_ice_fang"
end

modifier_item_ice_fang = class(itemBaseClass)
function modifier_item_ice_fang:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_item_ice_fang:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_ice_fang_debuff", {Duration = self:GetAbility():GetSpecialValueFor("duration")})
		end
	end
end

function modifier_item_ice_fang:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_ice_fang:IsHidden()
	return true
end

LinkLuaModifier( "modifier_ice_fang_debuff", "items/item_ice_fang.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_ice_fang_debuff = class({})

function modifier_ice_fang_debuff:OnCreated()
	self.slow = self:GetAbility():GetSpecialValueFor("slow")
	if IsServer() then
		if self:GetCaster():IsRealHero() then
			self.damage = self:GetAbility():GetSpecialValueFor("base_damage") + self:GetCaster():GetPrimaryStatValue() * self:GetAbility():GetSpecialValueFor("damage_over_time") / 100
		else
			self.damage = self:GetAbility():GetSpecialValueFor("base_damage") + self:GetCaster():GetPlayerOwner():GetAssignedHero():GetPrimaryStatValue() * self:GetAbility():GetSpecialValueFor("damage_over_time") / 100
		end
		self:StartIntervalThink(1)
	end
end

function modifier_ice_fang_debuff:OnRefresh()
	self:OnCreated()
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
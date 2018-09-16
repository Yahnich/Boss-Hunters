item_winters_breath = class({})

LinkLuaModifier( "modifier_item_winters_breath", "items/item_winters_breath.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_winters_breath:GetIntrinsicModifierName()
	return "modifier_item_winters_breath"
end

modifier_item_winters_breath = class(itemBaseClass)
function modifier_item_winters_breath:OnCreated()
	self.all = self:GetSpecialValueFor("bonus_all")
end

function modifier_item_winters_breath:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
			MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,}
end

function modifier_item_winters_breath:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			params.target:AddNewModifier(params.attacker, self:GetAbility(), "modifier_winters_breath_debuff", {Duration = self:GetAbility():GetSpecialValueFor("duration")})
		end
	end
end

function modifier_item_winters_breath:GetModifierBonusStats_Strength()
	return self.all
end

function modifier_item_winters_breath:GetModifierBonusStats_Agility()
	return self.all
end

function modifier_item_winters_breath:GetModifierBonusStats_Intellect()
	return self.all
end

LinkLuaModifier( "modifier_winters_breath_debuff", "items/item_winters_breath.lua" ,LUA_MODIFIER_MOTION_NONE )
modifier_winters_breath_debuff = class({})

function modifier_winters_breath_debuff:OnCreated()
	self.slow = self:GetAbility():GetSpecialValueFor("slow")
	if IsServer() then
		self.damage = self:GetAbility():GetSpecialValueFor("base_damage") + self:GetCaster():GetPrimaryStatValue() * self:GetAbility():GetSpecialValueFor("damage_over_time") / 100
		self:StartIntervalThink(1)
	end
end

function modifier_winters_breath_debuff:OnRefresh()
	self.slow = self:GetAbility():GetSpecialValueFor("slow")
	if IsServer() then
		self.damage = math.max( self.damage, self:GetAbility():GetSpecialValueFor("base_damage") + self:GetCaster():GetPrimaryStatValue() * self:GetAbility():GetSpecialValueFor("damage_over_time") / 100 )
	end
end

function modifier_winters_breath_debuff:OnIntervalThink()
	self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {damage_type = DAMAGE_TYPE_MAGICAL})
end

function modifier_winters_breath_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_winters_breath_debuff:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_winters_breath_debuff:GetEffectName()
	return "particles/generic_gameplay/generic_slowed_cold.vpcf"
end
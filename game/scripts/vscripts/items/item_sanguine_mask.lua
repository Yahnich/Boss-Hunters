item_sanguine_mask = class({})
LinkLuaModifier( "modifier_item_sanguine_mask_passive", "items/item_sanguine_mask.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_sanguine_mask:GetIntrinsicModifierName()
	return "modifier_item_sanguine_mask_passive"
end

modifier_item_sanguine_mask_passive = class(itemBaseClass)

function modifier_item_sanguine_mask_passive:OnCreated()
	self.lifesteal = self:GetSpecialValueFor("melee_lifesteal") / 100
	if self:GetParent():IsRangedAttacker() then
		self.lifesteal = self:GetSpecialValueFor("ranged_lifesteal") / 100
	end
end

function modifier_item_sanguine_mask_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_item_sanguine_mask_passive:OnTakeDamage(params)
	if params.attacker == self:GetParent() and params.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK and self:GetParent():GetHealth() > 0 and self:GetParent():IsRealHero() and not params.inflictor then
		local flHeal = params.damage * self.lifesteal
		params.attacker:HealEvent(flHeal, self:GetAbility(), params.attacker)
	end
end
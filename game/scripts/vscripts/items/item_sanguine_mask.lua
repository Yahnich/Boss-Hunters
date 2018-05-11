item_sanguine_mask = class({})
LinkLuaModifier( "modifier_item_sanguine_mask_passive", "items/item_sanguine_mask.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_sanguine_mask:GetIntrinsicModifierName()
	return "modifier_item_sanguine_mask_passive"
end

modifier_item_sanguine_mask_passive = class({})

function modifier_item_sanguine_mask_passive:OnCreated()
	self.lifesteal = self:GetSpecialValueFor("lifesteal") / 100
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

function modifier_item_sanguine_mask_passive:IsHidden()
	return true
end

function modifier_item_sanguine_mask_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
item_orb_of_renewal = class({})
LinkLuaModifier( "modifier_item_orb_of_renewal_passive", "items/item_orb_of_renewal.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_orb_of_renewal:GetIntrinsicModifierName()
	return "modifier_item_orb_of_renewal_passive"
end

modifier_item_orb_of_renewal_passive = class(itemBaseClass)

function modifier_item_orb_of_renewal_passive:OnCreated()
	self.mRestore = self:GetSpecialValueFor("mana_restore")
	self.hRestore = self:GetSpecialValueFor("heal_restore")
end

function modifier_item_orb_of_renewal_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function modifier_item_orb_of_renewal_passive:GetModifierPercentageCooldownStacking(params)
	return self.cdr
end

function modifier_item_orb_of_renewal_passive:OnAbilityFullyCast(params)	
	if params.unit == self:GetParent() and params.ability:GetCooldown(-1) > 0 then
		self:GetParent():RestoreMana(self.mRestore)
		self:GetParent():HealEvent(self.hRestore, self:GetAbility(), self:GetParent())
	end
end

function modifier_item_orb_of_renewal_passive:IsHidden()
	return true
end
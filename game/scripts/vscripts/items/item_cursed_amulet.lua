item_cursed_amulet = class({})

function item_cursed_amulet:GetIntrinsicModifierName()
	return "modifier_item_cursed_amulet"
end

modifier_item_cursed_amulet = class(itemBaseClass)
LinkLuaModifier( "modifier_item_cursed_amulet", "items/item_cursed_amulet.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_item_cursed_amulet:OnCreated()
	self.duration = self:GetSpecialValueFor("duration")
	self.chance = self:GetSpecialValueFor("chance")
end

function modifier_item_cursed_amulet:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_item_cursed_amulet:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() and self:RollPRNG( self.chance ) then
			params.target:DisableHealing(self.duration)
		end
	end
end
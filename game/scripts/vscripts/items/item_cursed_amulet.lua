item_cursed_amulet = class({})

LinkLuaModifier( "modifier_item_cursed_amulet", "items/item_cursed_amulet.lua" ,LUA_MODIFIER_MOTION_NONE )
function item_cursed_amulet:GetIntrinsicModifierName()
	return "modifier_item_cursed_amulet"
end

modifier_item_cursed_amulet = class({})
function modifier_item_cursed_amulet:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_item_cursed_amulet:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() and RollPercentage( self:GetSpecialValueFor("disable_chance") ) then
			params.target:DisableHealing(self:GetSpecialValueFor("duration"))
		end
	end
end

function modifier_item_cursed_amulet:IsHidden()
	return true
end
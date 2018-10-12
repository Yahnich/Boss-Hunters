item_ogre_club = class({})
function item_ogre_club:GetIntrinsicModifierName()
	return "modifier_item_ogre_club_handle"
end

modifier_item_ogre_club_handle = class(itemBaseClass)
LinkLuaModifier( "modifier_item_ogre_club_handle", "items/item_ogre_club.lua", LUA_MODIFIER_MOTION_NONE )

function modifier_item_ogre_club_handle:OnCreated()
	self.stat = self:GetSpecialValueFor("bonus_strength")
end

function modifier_item_ogre_club_handle:DeclareFunctions()
	return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS}
end

function modifier_item_ogre_club_handle:GetModifierBonusStats_Strength()
	return self.stat
end
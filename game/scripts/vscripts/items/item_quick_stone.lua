item_quick_stone = class(runeItemBaseClass)
LinkLuaModifier( "modifier_item_quick_stone_passive", "items/item_quick_stone.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_quick_stone:GetIntrinsicModifierName()
	return "modifier_item_quick_stone_passive"
end

function item_quick_stone:RuneProcessing( item, itemmodifier, slotIndex )
	item.itemData = item.itemData or {}
	local level = ( item.itemData[slotIndex].rune_level or 0 ) + 1
	item.itemData[slotIndex].rune_level = level
	item.itemData[slotIndex].funcs["GetModifierAttackSpeedBonus_Constant"] = (item.itemData[slotIndex].funcs["GetModifierAttackSpeedBonus_Constant"] or 0) + self:GetLevelSpecialValueFor( "attack_speed", level-1 )
end

modifier_item_quick_stone_passive = class(persistentModifier)

function modifier_item_quick_stone_passive:OnCreated()
	self.as = self:GetSpecialValueFor("attack_speed")
	if IsServer() then
		self:GetCaster():HookInModifier( "GetModifierAttackSpeedBonus_Constant", self )
	end
end

function modifier_item_quick_stone_passive:OnRefresh()
	self.as = self:GetSpecialValueFor("attack_speed")
	if IsServer() then
		self:GetCaster():HookInModifier( "GetModifierAttackSpeedBonus_Constant", self )
	end
end

function modifier_item_quick_stone_passive:OnDestroy()
	if IsServer() then
		self:GetCaster():HookOutModifier( "GetModifierAttackSpeedBonus_Constant", self )
	end
end

function modifier_item_quick_stone_passive:GetModifierAttackSpeedBonus_Constant()
	return self.as
end
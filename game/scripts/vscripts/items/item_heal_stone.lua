item_heal_stone = class(runeItemBaseClass)
LinkLuaModifier( "modifier_item_heal_stone_passive", "items/item_heal_stone.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_heal_stone:GetIntrinsicModifierName()
	return "modifier_item_heal_stone_passive"
end

function item_heal_stone:RuneProcessing( item, itemmodifier, slotIndex )
	item.itemData = item.itemData or {}
	local level = ( item.itemData[slotIndex].rune_level or 0 ) + 1
	item.itemData[slotIndex].rune_level = level
	item.itemData[slotIndex].baseFuncs["GetModifierHealAmplify_Percentage"] = (item.itemData[slotIndex].baseFuncs["GetModifierHealAmplify_Percentage"] or 0) + self:GetLevelSpecialValueFor( "heal_amp", level-1 )
end

modifier_item_heal_stone_passive = class(persistentModifier)

function modifier_item_heal_stone_passive:OnCreated()
	self:OnRefresh()
end

function modifier_item_heal_stone_passive:OnRefresh()
	self.heal_amp = 0
	for i = 1, self:GetAbility():GetCurrentCharges() do
		self.heal_amp = self.heal_amp + self:GetAbility():GetLevelSpecialValueFor( "heal_amp", i-1 )
	end
end

function modifier_item_heal_stone_passive:GetModifierHealAmplify_Percentage()
	return self.heal_amp
end



item_power_stone = class(runeItemBaseClass)
LinkLuaModifier( "modifier_item_power_stone_passive", "items/item_power_stone.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_power_stone:GetIntrinsicModifierName()
	return "modifier_item_power_stone_passive"
end

function item_power_stone:RuneProcessing( item, itemmodifier, slotIndex )
	item.itemData = item.itemData or {}
	local level = ( item.itemData[slotIndex].rune_level or 0 ) + 1
	item.itemData[slotIndex].rune_level = level
	item.itemData[slotIndex].baseFuncs["GetModifierSpellAmplify_Percentage"] = (item.itemData[slotIndex].baseFuncs["GetModifierSpellAmplify_Percentage"] or 0) + self:GetLevelSpecialValueFor( "spell_amp", level-1 )
end

modifier_item_power_stone_passive = class(persistentModifier)

function modifier_item_power_stone_passive:OnCreated()
	self:OnRefresh()
end

function modifier_item_power_stone_passive:OnRefresh()
	self.dmg = 0
	for i = 1, self:GetAbility():GetCurrentCharges() do
		self.dmg = self.dmg + self:GetAbility():GetLevelSpecialValueFor( "spell_amp", i-1 )
	end
end

function modifier_item_power_stone_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end

function modifier_item_power_stone_passive:GetModifierSpellAmplify_Percentage()
	return self.dmg
end
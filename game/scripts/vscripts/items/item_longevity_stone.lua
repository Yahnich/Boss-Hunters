item_longevity_stone = class(runeItemBaseClass)
LinkLuaModifier( "modifier_item_longevity_stone_passive", "items/item_longevity_stone.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_longevity_stone:GetIntrinsicModifierName()
	return "modifier_item_longevity_stone_passive"
end

function item_longevity_stone:RuneProcessing( item, itemmodifier, slotIndex )
	item.itemData = item.itemData or {}
	local level = ( item.itemData[slotIndex].rune_level or 0 ) + 1
	item.itemData[slotIndex].rune_level = level
	item.itemData[slotIndex].baseFuncs["GetModifierStatusAmplify_Percentage"] = (item.itemData[slotIndex].baseFuncs["GetModifierStatusAmplify_Percentage"] or 0) + self:GetLevelSpecialValueFor( "status_amp", level-1 )
end

modifier_item_longevity_stone_passive = class(persistentModifier)

function modifier_item_longevity_stone_passive:OnCreated()
	self:OnRefresh()
end

function modifier_item_longevity_stone_passive:OnRefresh()
	self.status_amp = 0
	for i = 1, self:GetAbility():GetCurrentCharges() do
		self.status_amp = self.status_amp + self:GetAbility():GetLevelSpecialValueFor( "status_amp", i-1 )
	end
end

function modifier_item_longevity_stone_passive:GetModifierStatusAmplify_Percentage()
	return self.status_amp
end

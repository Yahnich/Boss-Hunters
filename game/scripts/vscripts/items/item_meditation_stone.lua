item_meditation_stone = class(runeItemBaseClass)
LinkLuaModifier( "modifier_item_meditation_stone_passive", "items/item_meditation_stone.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_meditation_stone:GetIntrinsicModifierName()
	return "modifier_item_meditation_stone_passive"
end

function item_meditation_stone:RuneProcessing( item, itemmodifier, slotIndex )
	item.itemData = item.itemData or {}
	local level = ( item.itemData[slotIndex].rune_level or 0 ) + 1
	item.itemData[slotIndex].rune_level = level
	item.itemData[slotIndex].baseFuncs["GetModifierConstantManaRegen"] = (item.itemData[slotIndex].baseFuncs["GetModifierConstantManaRegen"] or 0) + self:GetLevelSpecialValueFor( "mana_regen", level-1 )
end

modifier_item_meditation_stone_passive = class(itemBasicBaseClass)

function modifier_item_meditation_stone_passive:OnCreated()
	self:OnRefresh()
end

function modifier_item_meditation_stone_passive:OnRefresh()
	self.mp_regen = 0
	for i = 1, self:GetAbility():GetCurrentCharges() do
		self.mp_regen = self.mp_regen + self:GetAbility():GetLevelSpecialValueFor( "mana_regen", i-1 )
	end
end

function modifier_item_meditation_stone_passive:DeclareFunctions()
	return {
				MODIFIER_PROPERTY_MANA_REGEN_CONSTANT 
			}
end

function modifier_item_meditation_stone_passive:GetModifierConstantManaRegen()
	return self.mp_regen
end
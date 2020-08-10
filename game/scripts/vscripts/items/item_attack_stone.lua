item_attack_stone = class(runeItemBaseClass)
LinkLuaModifier( "modifier_item_attack_stone_passive", "items/item_attack_stone.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_attack_stone:GetIntrinsicModifierName()
	return "modifier_item_attack_stone_passive"
end

function item_attack_stone:RuneProcessing( item, itemmodifier, slotIndex )
	item.itemData = item.itemData or {}
	local level = ( item.itemData[slotIndex].rune_level or 0 ) + 1
	item.itemData[slotIndex].rune_level = level
	item.itemData[slotIndex].funcs["GetModifierPreAttack_BonusDamage"] = (item.itemData[slotIndex].funcs["GetModifierPreAttack_BonusDamage"] or 0) + self:GetLevelSpecialValueFor( "attack_damage", level-1 )
end

modifier_item_attack_stone_passive = class(persistentModifier)

function modifier_item_attack_stone_passive:OnCreated()
	self.dmg = self:GetSpecialValueFor("attack_damage")
end

function modifier_item_attack_stone_passive:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function modifier_item_attack_stone_passive:GetModifierPreAttack_BonusDamage()
	return self.dmg
end
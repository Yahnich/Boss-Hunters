
if item_redium_lens_nostack == nil then
	item_redium_lens_nostack = class({})
end

function item_blink_staff_passive_modifier:IsHidden()
	return true --we want item's passive abilities to be hidden most of the times
end

function item_blink_staff_passive_modifier:DeclareFunctions() --we want to use these functions in this item
	local funcs = {
		MODIFIER_PROPERTY_MAGICDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS
	}
 
	return funcs
end

function item_blink_staff_passive_modifier:GetModifierBonusStats_Intellect()
	local hAbility = self:GetAbility() --we get the ability where this modifier is from
	return hAbility:GetSpecialValueFor( "bonus_int" )
end

function item_blink_staff_passive_modifier:GetModifierAttackSpeedBonus_Constant()
	local hAbility = self:GetAbility() --we get the ability where this modifier is from
	return hAbility:GetSpecialValueFor( "bonus_attack_speed" )
end

function item_blink_staff_passive_modifier:GetModifierPreAttack_BonusDamage()
	local hAbility = self:GetAbility() --we get the ability where this modifier is from
	return hAbility:GetSpecialValueFor( "bonus_damage" )
end
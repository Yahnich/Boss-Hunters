if lua_redium_lens_modifier == nil then
	lua_redium_lens_modifier = class({})
end

function lua_redium_lens_modifier:DeclareFunctions()
	local funcs = {
MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
MODIFIER_PROPERTY_MAGICDAMAGEOUTGOING_PERCENTAGE,
MODIFIER_PROPERTY_CAST_RANGE_BONUS
	}
	return funcs
end



function lua_redium_lens_modifier:OnCreated()
	print ("let's try some lua item")
end


function lua_redium_lens_modifier:IsHidden()
	return false
end

function lua_redium_lens_modifier:GetAttributes() 
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE
end

function lua_redium_lens_modifier:GetModifierMagicDamageOutgoing_Percentage()
	return 99999
end

function lua_redium_lens_modifier:GetModifierCastRangeBonus()
	return 9999
end

function lua_redium_lens_modifier:GetModifierBonusStats_Intellect()
	local hAbility = self:GetAbility() --we get the ability where this modifier is from
	return 999
end

function lua_redium_lens_modifier:GetModifierAttackSpeedBonus_Constant()
	local hAbility = self:GetAbility() --we get the ability where this modifier is from
	return 999
end

function lua_redium_lens_modifier:GetModifierPreAttack_BonusDamage()
	local hAbility = self:GetAbility() --we get the ability where this modifier is from
	return 99999
end
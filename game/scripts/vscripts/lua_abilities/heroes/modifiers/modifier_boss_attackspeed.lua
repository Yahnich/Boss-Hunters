modifier_boss_attackspeed = class({})

function modifier_boss_attackspeed:IsHidden()
	return true
end

function modifier_boss_attackspeed:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

--------------------------------------------------------------------------------

function modifier_boss_attackspeed:GetModifierAttackSpeedBonus_Constant( params )
	return 200
end



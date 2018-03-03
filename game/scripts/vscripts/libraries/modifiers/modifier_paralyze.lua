modifier_paralyze = class({})
function modifier_paralyze:GetTexture()
	return "harpy_storm_chain_lightning"
end

function modifier_paralyze:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
	return funcs
end

function modifier_paralyze:GetModifierMoveSpeedBonus_Percentage()
	return -100
end

function modifier_paralyze:IsDebuff()
	return true
end
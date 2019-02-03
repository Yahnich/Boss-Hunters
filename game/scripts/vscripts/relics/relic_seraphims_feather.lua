relic_seraphims_feather = class(relicBaseClass)

function relic_seraphims_feather:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT}
end

function relic_seraphims_feather:GetModifierMoveSpeedBonus_Constant()
	return 60
end
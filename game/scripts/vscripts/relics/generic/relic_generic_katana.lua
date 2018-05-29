relic_generic_katana = class(relicBaseClass)

function relic_generic_katana:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end

function relic_generic_katana:GetModifierPreAttack_CriticalStrike()
	if RollPercentage(20) then return 150 end
end
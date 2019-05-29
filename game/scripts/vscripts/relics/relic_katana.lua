relic_katana = class(relicBaseClass)

function relic_katana:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE}
end

function relic_katana:GetModifierPreAttack_CriticalStrike()
	if RollPercentage(20) then return 150 end
end
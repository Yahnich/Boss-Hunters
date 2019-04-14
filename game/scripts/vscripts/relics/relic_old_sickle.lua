relic_old_sickle = class(relicBaseClass)

function relic_old_sickle:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end
function relic_giants_cudgel:GetModifierAreaDamage(params)
	return 25
end
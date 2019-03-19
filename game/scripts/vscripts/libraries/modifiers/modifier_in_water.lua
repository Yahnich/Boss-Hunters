modifier_in_water = class({})
function modifier_in_water:GetTexture()
	return "naga_siren_rip_tide"
end

function modifier_in_water:GetEffectName()
	return "particles/units/heroes/hero_tidehunter/tidehunter_gush_slow.vpcf"
end

function modifier_in_water:GetStatusEffectName()
	return "particles/status_fx/status_effect_gush.vpcf"
end

function modifier_in_water:StatusEffectPriority()
	return 10
end
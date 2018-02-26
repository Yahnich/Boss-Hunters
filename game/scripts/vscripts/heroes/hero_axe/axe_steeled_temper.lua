function AxeSteeledTemper(keys)
	local caster = keys.caster
    local ability = keys.ability
	
	local strength = caster:GetStrength()
	
	caster:SetModifierStackCount("modifier_axe_steeled_temper", caster, strength)
end
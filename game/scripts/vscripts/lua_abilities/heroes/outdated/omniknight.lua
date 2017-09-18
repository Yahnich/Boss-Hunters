function AOEPurificationDamage(keys)
	ApplyDamage({victim = keys.target, attacker = keys.caster, damage = keys.ability:GetTalentSpecialValueFor("damage"), damage_type = keys.ability:GetAbilityDamageType(), ability = keys.ability})
end

function CheckOmniScepter(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifier = keys.modifier
	local sceptermodifier = keys.sceptermodifier
	local targetTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY
    local targetType = DOTA_UNIT_TARGET_ALL
    local targetFlag = ability:GetAbilityTargetFlags()
	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, FIND_UNITS_EVERYWHERE, targetTeam, targetType, ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
    for _,unit in pairs( units ) do
		if caster:HasScepter() or HasCustomScepter(caster) then
		local duration_scepter = ability:GetTalentSpecialValueFor("duration_scepter")
		ability:ApplyDataDrivenModifier(caster, unit, sceptermodifier, {duration = duration_scepter})
		else
		local duration = ability:GetTalentSpecialValueFor("duration")
		ability:ApplyDataDrivenModifier(caster, unit, modifier, {duration = duration})
		end
	end
end
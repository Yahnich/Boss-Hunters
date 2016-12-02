function HunterInTheNight( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifier = keys.modifier
	local bat = caster:GetBaseAttackTime()
	local new_bat = ability:GetLevelSpecialValueFor("bonus_base_attack_time_night", ability:GetLevel()-1)

	if not GameRules:IsDaytime() then
		ability:ApplyDataDrivenModifier(caster, caster, ("modifier_hunter_in_the_night_buff_ebf"), {})
		caster:RemoveModifierByName("modifier_hunter_in_the_night_bat_ebf")
		bat = caster:GetBaseAttackTime()
		if bat >= new_bat then
			ability:ApplyDataDrivenModifier(caster, caster, ("modifier_hunter_in_the_night_bat_ebf"), {})
		end
		if caster:HasScepter() and caster:HasModifier("modifier_night_stalker_darkness") then
			ability:ApplyDataDrivenModifier(caster, caster, ("modifier_hunter_in_the_night_scepter"), {})
		else 
			caster:RemoveModifierByName("modifier_hunter_in_the_night_scepter")
		end
	else
		if caster:HasModifier(modifier) then 
			caster:RemoveModifierByName(modifier)
			caster:RemoveModifierByName("modifier_hunter_in_the_night_bat_ebf")
			caster:RemoveModifierByName("modifier_hunter_in_the_night_scepter")
		end
	end
end

function Void( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local modifier = keys.modifier

	local duration_day = ability:GetLevelSpecialValueFor("duration_day", (ability:GetLevel() - 1))
	local duration_night = ability:GetLevelSpecialValueFor("duration_night", (ability:GetLevel() - 1))

	if GameRules:IsDaytime() then
		ability:ApplyDataDrivenModifier(caster, target, modifier, {duration = duration_day})
	else
		ability:ApplyDataDrivenModifier(caster, target, modifier, {duration = duration_night})
	end
	ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType(), ability = ability})
end
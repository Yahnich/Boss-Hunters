function HunterInTheNight( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifier = keys.modifier
	local bat = caster:GetBaseAttackTime()
	local new_bat = ability:GetTalentSpecialValueFor("bonus_base_attack_time_night")

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
		if caster:HasTalent("special_bonus_unique_night_stalker_2") then
			ability:ApplyDataDrivenModifier(caster, caster, ("modifier_hunter_in_the_night_talent"), {})
		end
	else
		if caster:HasModifier(modifier) then 
			caster:RemoveModifierByName(modifier)
			caster:RemoveModifierByName("modifier_hunter_in_the_night_bat_ebf")
			caster:RemoveModifierByName("modifier_hunter_in_the_night_scepter")
			caster:RemoveModifierByName("modifier_hunter_in_the_night_talent")
		end
	end
end

function Void( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local modifier = keys.modifier

	local duration_day = ability:GetTalentSpecialValueFor("duration_day")
	local duration_night = ability:GetTalentSpecialValueFor("duration_night")
	local dmgmult = 1
	if GameRules:IsDaytime() then
		ability:ApplyDataDrivenModifier(caster, target, modifier, {duration = duration_day})
	else
		ability:ApplyDataDrivenModifier(caster, target, modifier, {duration = duration_night})
		dmgmult = ability:GetTalentSpecialValueFor("damage_amp_night") / 100
	end
	ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage() * dmgmult, damage_type = ability:GetAbilityDamageType(), ability = ability})
end
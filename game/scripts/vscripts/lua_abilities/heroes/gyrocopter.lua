function RocketDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType(), ability = ability})
end

function SupportRocketProcCheck(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	if ability:IsCooldownReady() then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_supporting_rockets_proc", {})
		ability:StartCooldown(ability:GetTrueCooldown())
	end
end

function SupportDOT(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target

	ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage()/ability:GetTalentSpecialValueFor("dot_duration"), damage_type = ability:GetAbilityDamageType(), ability = ability})
end

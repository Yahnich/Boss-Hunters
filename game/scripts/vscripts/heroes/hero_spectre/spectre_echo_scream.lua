spectre_echo_scream = class({})

function ScreamApply(keys)
	local modifierName = "modifier_echo_scream_daze"
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
	ability:ApplyDataDrivenModifier( caster, target, modifierName, {duration = ability:GetDuration()} )
	ApplyDamage({ victim = target, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType(), ability = ability })
	if caster:HasScepter() then
		local stacks = ability:GetTalentSpecialValueFor("scepter_scream_attacks")
		for i = 1, stacks do
			caster:PerformAttack(target, true, true, true, false, false, false, true)
		end
	end
end


"FireSound"
			{
				"EffectName"	"Hero_Spectre.Reality"
				"Target"		"CASTER"
			}
			"AttachEffect"
			{
				"EffectName"	"particles/spectre_echo_scream.vpcf"
				"EffectAttachType"	"attach_origin"
				"Target"		"CASTER"
			}
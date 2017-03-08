function HauntFunction(keys)
    local modifierName = "haunt"
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    if not caster:IsIllusion() then
        if target:HasModifier( modifierName ) then
            local current_stack = target:GetModifierStackCount( modifierName, ability )
            ability:ApplyDataDrivenModifier( caster, target, modifierName, nil )
            target:SetModifierStackCount( modifierName, ability, current_stack + 1 )
        else
            ability:ApplyDataDrivenModifier( caster, target, modifierName, nil)
            target:SetModifierStackCount( modifierName, ability, 1)
        end
    end
end

function ScreamApply(keys)
	local modifierName = "modifier_echo_scream_daze"
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
	print(ability:GetAbilityDamage(), ability:GetAbilityDamageType())
	ability:ApplyDataDrivenModifier( caster, target, modifierName, {duration = ability:GetDuration()} )
	ApplyDamage({ victim = target, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType(), ability = ability })
	if caster:HasScepter() then
		local stacks = ability:GetTalentSpecialValueFor("scream_haunt_stacks")
		for i = 1, stacks do
			caster:PerformAttack(target, true, true, true, false, false, false, true)
		end
	end
end
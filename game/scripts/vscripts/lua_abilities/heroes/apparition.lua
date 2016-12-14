function ApplyEntropy(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	if not target:HasModifier("modifier_entropy_damage_reduction") then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_entropy_damage_reduction", {duration = 4})
	else
		target:SetModifierStackCount("modifier_entropy_damage_reduction", caster, target:GetModifierStackCount("modifier_entropy_damage_reduction", caster) + 1)
	end
	ApplyDamage({victim = target, attacker = caster, damage = ability:GetTalentSpecialValueFor("damage"), damage_type = ability:GetAbilityDamageType(), ability = ability})
end
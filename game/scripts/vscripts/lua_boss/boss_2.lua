function DamageOverTime(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local tickrate = 0.1
	target.stackTable = target.stackTable or {}
	local modifier = target:FindModifierByName("modifier_boss_toxic_weaponry_debuff")
	if #target.stackTable > 0 then
		local expireTime = ability:GetSpecialValueFor("debuff_duration")
		for i = #target.stackTable, 1, -1 do
			if target.stackTable[i] + expireTime < GameRules:GetGameTime() then
				table.remove(target.stackTable, i)
				modifier:DecrementStackCount()
			end
		end
	end
	ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage() * tickrate * modifier:GetStackCount(), damage_type = ability:GetAbilityDamageType(), ability = ability})
end

function HandleStacks(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	target.stackTable = target.stackTable or {}
	table.insert(target.stackTable, GameRules:GetGameTime())
	ability:ApplyDataDrivenModifier(caster, target, "modifier_boss_toxic_weaponry_debuff", {duration = ability:GetSpecialValueFor("debuff_duration")})
	local modifier = target:FindModifierByName("modifier_boss_toxic_weaponry_debuff")
	modifier:SetStackCount(#target.stackTable)
end
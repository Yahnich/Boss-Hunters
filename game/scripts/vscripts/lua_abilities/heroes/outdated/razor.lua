function HandleHighVoltageStacks(keys)
	local unit = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local freq = keys.tick
	local duration = ability:GetTalentSpecialValueFor("slow_duration")
	if keys.modifier == "razor_high_voltage_buff_ms_haste" then duration = ability:GetTalentSpecialValueFor("buff_duration") end
	if not unit:HasModifier(keys.modifier) then
		local startslow = ability:GetTalentSpecialValueFor("slow_amount")
		if keys.modifier == "razor_high_voltage_buff_ms_haste" then startslow = ability:GetTalentSpecialValueFor("haste_amount") end
		ability:ApplyDataDrivenModifier(caster, unit, keys.modifier, {duration = duration})
		unit:SetModifierStackCount(keys.modifier, caster, startslow)
	else
		local currstacks = unit:GetModifierStackCount(keys.modifier, caster)
		local startslow = ability:GetTalentSpecialValueFor("slow_amount")
		if keys.modifier == "razor_high_voltage_buff_ms_haste" then startslow = ability:GetTalentSpecialValueFor("haste_amount") end
		local reduction = startslow * freq / duration
		unit:SetModifierStackCount(keys.modifier, caster, currstacks - reduction)
	end
end

function HighVoltageDamage(keys)
	if keys.attacker:GetTeam() ~= keys.caster:GetTeam() then
		local damageTable = {
			victim = keys.attacker,
			attacker = keys.caster,
			damage = keys.ability:GetAbilityDamage(),
			damage_type = keys.ability:GetAbilityDamageType(),
			ability = keys.ability
		}
		ApplyDamage( damageTable )
	end
end
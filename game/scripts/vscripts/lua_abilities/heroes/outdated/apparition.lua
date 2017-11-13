LinkLuaModifier("modifier_charges", "lua_abilities/heroes/modifiers/modifier_charges", LUA_MODIFIER_MOTION_NONE)
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

function EntropyTalent(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not caster:HasModifier("modifier_charges") and caster:HasTalent("special_bonus_unique_ancient_apparition_1") then
		caster:AddNewModifier(caster, ability, "modifier_charges",
        {
            max_count = caster:FindTalentValue("special_bonus_unique_ancient_apparition_1"),
            start_count = caster:FindTalentValue("special_bonus_unique_ancient_apparition_1"),
            replenish_time = ability:GetCooldown(-1)
        })
	end
end
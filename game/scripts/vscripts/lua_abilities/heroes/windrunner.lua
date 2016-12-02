function PierceDamage(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local pierce = ability:GetSpecialValueFor("pierce_pct") / 100
	local duration = ability:GetSpecialValueFor("stun_duration")
	local basedmg = ability:GetSpecialValueFor("base_damage")
    local damage = keys.damage*pierce + basedmg
	if caster:IsIllusion() then return end
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, caster, damage, nil)
    local damageTable = {victim = target,
                attacker = caster,
                damage = damage/get_aether_multiplier(caster),
                damage_type = DAMAGE_TYPE_PURE,
                ability = ability,
                }
    ApplyDamage(damageTable)
	target:AddNewModifier(caster, ability, "modifier_stunned", {duration = duration})
end

function PierceRNG(keys)
    local ability = keys.ability
	if not ability:IsCooldownReady() then return end
	local caster = keys.caster
    local target = keys.target
	local proc = ability:GetSpecialValueFor("proc_chance")
	local cooldown = ability:GetSpecialValueFor("passive_cooldown")
	if caster:HasModifier("modifier_focusfire_crit_scepter") then cooldown = 0 end
	if not ability.prng then ability.prng = 0 end
	if math.random(100) < proc + ability.prng then
		ability:ApplyDataDrivenModifier(caster,caster, keys.modifier, {})
		ability.prng = 0
		ability:StartCooldown(cooldown*get_octarine_multiplier(caster))
	else
		ability.prng = ability.prng + 1
	end
end

function FocusFireScepterCheck(keys)
	local caster = keys.caster
    local ability = keys.ability
	local modifier = keys.modifier
	if caster:HasScepter() then
		ability:ApplyDataDrivenModifier(caster,caster,modifier.."_scepter", {duration = ability:GetDuration()})
	else
		ability:ApplyDataDrivenModifier(caster,caster,modifier, {duration = ability:GetDuration()})
	end
	ability:ApplyDataDrivenModifier(caster,caster,keys.bat, {duration = ability:GetDuration()})
end
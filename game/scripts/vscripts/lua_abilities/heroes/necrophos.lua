require("libraries/utility")

function SelfDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local selfDamagePct = ability:GetSpecialValueFor("self_damage")/100
	ability.sacrifice = selfDamagePct*caster:GetHealth()
	caster:SetHealth(caster:GetHealth()-ability.sacrifice)
	local selfhurt = ParticleManager:CreateParticle("particles/necrophos_plague.vpcf", PATTACH_ABSORIGIN  , keys.caster)
    ParticleManager:SetParticleControl(selfhurt, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(selfhurt, 3, caster:GetAbsOrigin())
end

function AllyHeal(keys)
	local ability = keys.ability
	local target = keys.target
	local caster = keys.caster
	
	local tickrate = ability:GetSpecialValueFor("tick_rate")
	local duration = ability:GetSpecialValueFor("duration")
	local healpct = ability:GetLevelSpecialValueFor("heal_per_health", -1)/100
	local base_heal = ability:GetLevelSpecialValueFor("base_heal", -1)
	local healtick = (ability.sacrifice*healpct + base_heal)/(duration/tickrate)
	if target:GetMaxHealth() - target:GetHealth() < healtick then
		local difference = healtick - (target:GetMaxHealth() - target:GetHealth())
		if target:HasModifier("modifier_plague_health_increase") then
			local stacks = target:GetModifierStackCount("modifier_plague_health_increase", caster)
			target:SetModifierStackCount("modifier_plague_health_increase", caster, stacks + difference)
			print("trigger1")
		else
			ability:ApplyDataDrivenModifier(caster, target, "modifier_plague_health_increase", {})
			target:SetModifierStackCount("modifier_plague_health_increase", caster, difference)
			print("trigger2")
		end
	end
	target:CalculateStatBonus()
	target:Heal(healtick, caster)
	target:Purge(false, true, false, true, true)
	if target.selfhurt then ParticleManager:DestroyParticle(target.selfhurt,true) end
	target.selfhurt = ParticleManager:CreateParticle("particles/units/heroes/hero_necrolyte/necrolyte_scythe_mist.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(target.selfhurt, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(target.selfhurt, 2, target:GetAbsOrigin())
end

function RemoveBonusHealth(keys)
	local health = keys.target:GetHealth()
	print("check")
	keys.target:RemoveModifierByName("modifier_plague_health_increase")
	if health > keys.target:GetMaxHealth() then health = keys.target:GetMaxHealth() end
	keys.target:SetHealth(health)
end

function EnemyDamage(keys)
	local ability = keys.ability
	local target = keys.target
	
	local tickrate = ability:GetSpecialValueFor("tick_rate")
	local duration = ability:GetSpecialValueFor("duration")
	local damagepct = ability:GetLevelSpecialValueFor("damage_per_health", -1)/100
	local base_damage = ability:GetLevelSpecialValueFor("base_damage", -1)
	local damagetick = (ability.sacrifice*damagepct+ base_damage)/(keys.caster:GetSpellDamageAmp()*(duration/tickrate))
	local damageType = ability:GetAbilityDamageType()
	if keys.caster:HasScepter() then damageType = DAMAGE_TYPE_PURE end
	ability.damage_flags = DOTA_DAMAGE_FLAG_HPLOSS
	ApplyDamage({victim = target, attacker = keys.caster, damage = damagetick, damage_type = damageType, damage_flags = DOTA_DAMAGE_FLAG_HPLOSS, ability = ability})
	
	if target.selfhurt then ParticleManager:DestroyParticle(target.selfhurt,true) end
	target.selfhurt = ParticleManager:CreateParticle("particles/units/heroes/hero_necrolyte/necrolyte_scythe_mist.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(target.selfhurt, 0, target:GetAbsOrigin())
    ParticleManager:SetParticleControl(target.selfhurt, 2, target:GetAbsOrigin())
end
function ApplyExplosion(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local duration = ability:GetTalentSpecialValueFor("base_duration")
	if caster:HasScepter() then
		local affectedEnemies = 0
		for _,unit in pairs(Entities:FindAllByName( "npc_dota_creature")) do
			if unit:HasModifier("modifier_abyssal_underlord_atrophy_aura_effect") then
				affectedEnemies = affectedEnemies + 1
			end
		end
		local duration = duration + affectedEnemies * ability:GetTalentSpecialValueFor("bonus_duration_per_aura_affected_scepter")
	end
	ability:ApplyDataDrivenModifier(caster, target, "modifier_underlord_expulsion_explosion", {duration = duration})
end

function ExplosionDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local damage = ability:GetTalentSpecialValueFor("damage_per_sec")
	if caster:HasScepter() then
		local affectedEnemies = 0
		for _,unit in pairs(Entities:FindAllByName( "npc_dota_creature")) do
			if unit:HasModifier("modifier_abyssal_underlord_atrophy_aura_effect") then
				affectedEnemies = affectedEnemies + 1
			end
		end
		local damage = damage + affectedEnemies * ability:GetTalentSpecialValueFor("bonus_damage_per_aura_affected_scepter")
	end
	local damage_tick = damage * ability:GetTalentSpecialValueFor("explosion_interval")
	ApplyDamage({victim = target, attacker = caster, damage = damage_tick, damage_type = ability:GetAbilityDamageType(), ability = ability})
end

function ExplosionHeal(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	local heal = ability:GetTalentSpecialValueFor("heal_per_sec")
	if caster:HasScepter() then
		local affectedEnemies = 0
		for _,unit in pairs(Entities:FindAllByName( "npc_dota_creature")) do
			if unit:HasModifier("modifier_abyssal_underlord_atrophy_aura_effect") then
				affectedEnemies = affectedEnemies + 1
			end
		end
		local heal = heal + affectedEnemies * ability:GetTalentSpecialValueFor("bonus_heal_per_aura_affected_scepter")
	end
	local heal_tick = heal * ability:GetTalentSpecialValueFor("explosion_interval")
	target:HealEvent(heal_tick, ability, caster)
end

function ApplyAttack(keys)
	local ability	= keys.ability
	local caster	= keys.caster
	local thinker	= keys.target
	caster:PerformAttack(target, true, true, true, false, true, false, false)
end

function Thinker_StoreCaster( keys )
	local ability	= keys.ability
	local caster	= keys.caster
	local thinker	= keys.target
	ability.radius = keys.coil_break_radius
	ability.breakradius = keys.coil_break_radius
	thinker.dream_coil_caster	= caster
	ability.dream_coil_thinker	= thinker
end

--[[
	Author: Ractidous
	Date: 23.02.2015.
	Apply modifier to the enemy
]]
function Thinker_ApplyModifierToEnemy( keys )
	local ability	= keys.ability
	local thinker	= ability.dream_coil_thinker
	local enemy		= keys.target
	local damage = ability:GetTalentSpecialValueFor("coil_init_damage_tooltip")
	ApplyDamage({victim = enemy, attacker = keys.caster, damage = damage, damage_type = ability:GetAbilityDamageType(), ability = ability})

	ability:ApplyDataDrivenModifier( thinker, enemy, keys.modifier_name, {} )
end

--[[
	Author: Ractidous
	Date: 23.02.2015.
	Check to see if the coil gets broken.
]]
function CheckCoilBreak( keys )
	local thinker	= keys.caster
	local enemy		= keys.target
	local ability	= keys.ability
	local breakradius = keys.coil_break_radius
	if not enemy.radius then
		enemy.radius = breakradius
	end
	local tickrate = breakradius/(ability:GetTalentSpecialValueFor("coil_duration")/0.03) -- 0.03 is thinkinterval
	local dist	= (enemy:GetAbsOrigin() - thinker:GetAbsOrigin()):Length2D()
	if dist > enemy.radius then
		-- Link has been broken
		local caster	= thinker.dream_coil_caster

		ability:ApplyDataDrivenModifier( caster, enemy, keys.coil_break_modifier, {} )

		-- Remove this modifier
		enemy:RemoveModifierByNameAndCaster( keys.coil_tether_modifier, thinker )
	else
		enemy.radius = enemy.radius - tickrate
	end
end
function BreakDamage(keys)
	local enemy = keys.unit
	local caster = keys.caster
	local damage = keys.ability:GetTalentSpecialValueFor("coil_break_damage")
	ApplyDamage({victim = enemy, attacker = caster, damage = damage, damage_type = keys.ability:GetAbilityDamageType(), ability = keys.ability})
end

function ApplyPull(keys)
	local caster = keys.caster
	local radius = keys.ability:GetTalentSpecialValueFor("suck_radius")
	local duration = keys.ability:GetTalentSpecialValueFor("suck_duration")
	local start_effect = ParticleManager:CreateParticle("particles/reverie_snap_pull_start.vpcf", PATTACH_ABSORIGIN_FOLLOW , caster)
            ParticleManager:SetParticleControl(start_effect, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(start_effect, 1, caster:GetAbsOrigin())
	local pull_effect = ParticleManager:CreateParticle("particles/reverie_snap_pull.vpcf", PATTACH_ABSORIGIN , caster)
            ParticleManager:SetParticleControl(pull_effect, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(pull_effect, 1, Vector(radius,radius,radius))
			ParticleManager:SetParticleControl(pull_effect, 2, caster:GetAbsOrigin())
	
	local nearbyUnits = FindUnitsInRadius(caster:GetTeam(),
                                  caster:GetAbsOrigin(),
                                  nil,
                                  radius,
                                  DOTA_UNIT_TARGET_TEAM_ENEMY,
                                  DOTA_UNIT_TARGET_ALL,
                                  DOTA_UNIT_TARGET_FLAG_NONE,
                                  FIND_ANY_ORDER,
                                  false)
	for _,unit in pairs(nearbyUnits) do
		local distance = (unit:GetAbsOrigin()-caster:GetAbsOrigin()):Length2D()
		unit.speed = distance/duration * 1/30 -- 1/30 is how often the motion controller ticks
		unit.direction = (unit:GetAbsOrigin()-caster:GetAbsOrigin()):Normalized()
		keys.ability:ApplyDataDrivenModifier( caster, unit, keys.pull_modifier, {duration = duration})
		local rope_effect = ParticleManager:CreateParticle("particles/reverie_snap_pull_rope.vpcf", PATTACH_ABSORIGIN_FOLLOW , unit)
            ParticleManager:SetParticleControl(rope_effect, 0, unit:GetAbsOrigin())
	end
end

function PuckPull(keys)
	local caster = keys.caster
	local unit = keys.target
	local ability = keys.ability
	local coil_radius = ability:GetTalentSpecialValueFor("coil_radius")
	local distance = (unit:GetAbsOrigin()-caster:GetAbsOrigin()):Length2D()
	local direction = (unit:GetAbsOrigin()-caster:GetAbsOrigin()):Normalized()
	if distance > coil_radius/2 and unit:HasModifier("modifier_vacuum_pull_active") then
		unit:SetAbsOrigin(unit:GetAbsOrigin() - direction * unit.speed)
	else
		-- Remove the motion controller once the distance has been traveled
		unit:InterruptMotionControllers(false)
	end
end
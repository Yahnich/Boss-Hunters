function Rift(keys)
	local point = keys.target_points[1]
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	local difference = point - casterPos
	local ability = keys.ability
	local range = ability:GetCastRange()

	if difference:Length2D() > range then
		point = casterPos + (point - casterPos):Normalized() * range
	end
	
	local posIndex = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/abbysal_underlord_darkrift_ambient.vpcf", PATTACH_ABSORIGIN, caster)
						ParticleManager:SetParticleControl(posIndex, 0, casterPos)
						ParticleManager:SetParticleControl(posIndex, 2, casterPos)
						ParticleManager:SetParticleControl(posIndex, 5, casterPos)
	Timers:CreateTimer( 0.5, function()
		ParticleManager:DestroyParticle( posIndex, false )
		return nil
		end
	)

	FindClearSpaceForUnit(caster, point, false)
	ProjectileManager:ProjectileDodge(caster)
	
	local blinkIndex = ParticleManager:CreateParticle("particles/units/heroes/heroes_underlord/abyssal_underlord_darkrift_target.vpcf", PATTACH_ABSORIGIN, caster)
						ParticleManager:SetParticleControl(blinkIndex, 0, point)
						ParticleManager:SetParticleControl(blinkIndex, 6, point)
	Timers:CreateTimer( 1, function()
		ParticleManager:DestroyParticle( blinkIndex, false )
		return nil
		end
	)
end

function Vacuum( keys )
	local caster = keys.caster
	local target = keys.target
	local target_location = target:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Ability variables
	local duration = ability:GetLevelSpecialValueFor("duration", ability_level)
	local radius = ability:GetLevelSpecialValueFor("radius", ability_level)
	local vacuum_modifier = keys.vacuum_modifier
	
	local remaining_duration = duration - (GameRules:GetGameTime() - target.vacuum_start_time)

	-- Targeting variables
	local target_teams = ability:GetAbilityTargetTeam() 
	local target_types = ability:GetAbilityTargetType() 
	local target_flags = ability:GetAbilityTargetFlags() 

	local units = FindUnitsInRadius(caster:GetTeamNumber(), target_location, nil, radius, target_teams, target_types, target_flags, FIND_CLOSEST, false)

	-- Calculate the position of each found unit
	for _,unit in ipairs(units) do
		local unit_location = unit:GetAbsOrigin()
		local vector_distance = target_location - unit_location
		local distance = (vector_distance):Length2D()
		local direction = (vector_distance):Normalized()

		-- Check if its a new vacuum cast
		-- Set the new pull speed if it is
		if unit.vacuum_caster ~= target then
			unit.vacuum_caster = target
			-- The standard speed value is for 1 second durations so we have to calculate the difference
			-- with 1/duration
			unit.vacuum_caster.pull_speed = distance * 1/duration * 1/30
		end

		-- Apply the stun and no collision modifier then set the new location
		ability:ApplyDataDrivenModifier(caster, unit, vacuum_modifier, {duration = remaining_duration})
		unit:SetAbsOrigin(unit_location + direction * unit.vacuum_caster.pull_speed)

	end
end

function VacuumStart( keys )
	local target = keys.target

	target.vacuum_start_time = GameRules:GetGameTime()
end

function Sweep( keys )
	local caster = keys.caster
	local unit = keys.target
	local ability = keys.ability
	local coil_radius = ability:GetCastRange()
	local distance = (unit:GetAbsOrigin()-caster:GetAbsOrigin()):Length2D()
	local direction = (unit:GetAbsOrigin()-caster:GetAbsOrigin()):Normalized()
	if distance > 300 and unit:HasModifier("modifier_vacuum_thinker_datadriven") then
		unit:SetAbsOrigin(unit:GetAbsOrigin() - direction * 50)
	else
		-- Remove the motion controller once the distance has been traveled
		unit:InterruptMotionControllers(false)
		ResolveNPCPositions(unit:GetAbsOrigin(), 100)
	end
end

function CreatePool(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetCastRange()
	local randomPos = caster:GetAbsOrigin() + Vector(math.random(-radius,radius),math.random(-radius,radius), 0)
	local thinker =  CreateUnitByName( "npc_dummy_unit", randomPos, false, caster, caster, caster:GetTeamNumber() )
    ability:ApplyDataDrivenModifier(caster, thinker, "modifier_gravity_well_thinker", {duration = ability:GetChannelTime()})
	thinker.particleIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_enigma/enigma_midnight_pulse.vpcf", PATTACH_ABSORIGIN, thinker)
						ParticleManager:SetParticleControl(thinker.particleIndex, 0, randomPos)
						ParticleManager:SetParticleControl(thinker.particleIndex, 1, Vector(0,0,0))
	thinker.radius = 0
end

function GrowPool(keys)
	local ability = keys.ability
	local thinker = keys.target
	local caster = keys.caster
	local damagepct = ability:GetSpecialValueFor("damage_per_sec") / 500
	if not caster:IsChanneling() then
		thinker:RemoveModifierByName("modifier_gravity_well_thinker")
		return
	end
	local damageamp = 1
	if keys.caster:HasAbility("new_game_damage_increase") then
		damageamp = caster:GetSpellDamageAmp()
	end
	local growth = ability:GetSpecialValueFor("radius_growth_speed")
	if thinker.radius then
		thinker.radius = thinker.radius + growth / 5
		local units = FindUnitsInRadius(caster:GetTeam(),
                              thinker:GetAbsOrigin(),
                              caster,
                              thinker.radius,
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
		for _,unit in pairs(units) do
			local damageTable = {
                                victim = unit,
                                attacker = caster,
                                damage = unit:GetMaxHealth() * damagepct / damageamp,
                                damage_type = DAMAGE_TYPE_PURE,
								ability = ability
                            }
            ApplyDamage(damageTable)
		end
	end
	if thinker.particleIndex then
		ParticleManager:SetParticleControl(thinker.particleIndex, 1, Vector(thinker.radius,thinker.radius,thinker.radius))
	end
end

function KillYourself(keys)
	local thinker = keys.target
	thinker:Destroy()
	if not thinker:IsNull() then
		thinker:RemoveSelf()
	end
end

function LiftHeroes(keys)
	local ability = keys.ability
	local caster = keys.caster
	local unitstolift = ability:GetSpecialValueFor("heroes_per_second")
	local duration = ability:GetSpecialValueFor("stun_time")
	local units = FindUnitsInRadius(caster:GetTeam(),
                              caster:GetAbsOrigin(),
                              caster,
                              ability:GetCastRange(),
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
                              FIND_ANY_ORDER,
                              false)
	local liftedunits = 0
	for _,unit in pairs(units) do
		if not unit.hasBeenLifted and liftedunits < unitstolift then
			unit.hasBeenLifted = true
			liftedunits = liftedunits + 1
			ability:ApplyDataDrivenModifier(caster,unit, "modifier_graviton_slam_lift", {duration = duration})
		end
	end
end

function Lift(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	ability.target = target
	target.target_origin = target:GetAbsOrigin()
	
	local duration = ability:GetSpecialValueFor("stun_time")
	
	-- Renders the lift particle on the target
	target.lift_particle = ParticleManager:CreateParticle("particles/boss_particle/boss_graviton_slam.vpcf" , PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(target.lift_particle, 0, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(target.lift_particle, 1, target:GetAbsOrigin())
	ParticleManager:SetParticleControl(target.lift_particle, 2, Vector(duration,0,0))	
end

--[[Author: YOLOSPAGHETTI
	Date: July 11, 2016
	Moves the target to the drop position]]
function Fall(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	target.point = target.target_origin
	vector_distance = target.target_origin - target:GetAbsOrigin()
	
	-- Sets the distance the target must fall for every interval
	if ability.fall_distance == nil then
		local distance = (vector_distance):Length2D()
			
		local fall_duration = 0.3
		local intervals = fall_duration/0.01
	
		ability.fall_distance = distance/(intervals - 1)
	end
	
	-- Direction and position variables
	local direction = (vector_distance):Normalized()
	local new_position = target:GetAbsOrigin() + (direction * ability.fall_distance)
	
	-- Moves the target
	target:SetAbsOrigin(new_position)
	-- Creates awkward animation, but necessary for no clipping
	FindClearSpaceForUnit(target, new_position, true)
	target.hasBeenLifted = false
end

--[[Author: YOLOSPAGHETTI
	Date: July 11, 2016
	Applies the stun in the AOE]]
function Impact(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local radius = 325
	local stun_duration = ability:GetLevelSpecialValueFor("stun_time", (ability:GetLevel() -1))
	local is_target = false
	
	-- Destroys all previous particles
	ParticleManager:DestroyParticle(target.lift_particle, true)
	if ability.drop_particle ~= nil then
		ParticleManager:DestroyParticle(ability.drop_particle, true)
	end
	-- Renders the impact particle on the target
	local particle = ParticleManager:CreateParticleForTeam(keys.particle, PATTACH_WORLDORIGIN, caster, caster:GetTeam())
	ParticleManager:SetParticleControl(particle, 0, Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, target:GetAbsOrigin().z))
	ParticleManager:SetParticleControl(particle, 1, Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, target:GetAbsOrigin().z))
	ParticleManager:SetParticleControl(particle, 2, Vector(target:GetAbsOrigin().x, target:GetAbsOrigin().y, target:GetAbsOrigin().z))
	if caster:IsChanneling() then
		ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = DAMAGE_TYPE_MAGICAL, ability = ability})
	end
	-- Units to be caught in the stun
	local units = FindUnitsInRadius(caster:GetTeamNumber(), target.point, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), 0, 0, false)

	-- Applies the stun to all units in the AOE except the target
	for i,unit in ipairs(units) do
		if unit ~= target then
			unit:AddNewModifier(caster, ability, "modifier_stunned", {Duration = stun_duration})
			is_target = true
		end
	end
	
	-- Plays the impact sound if there is atleast one target
	if is_target == true then
		EmitSoundOn(keys.sound, target)
	end
	
	ability.fall_distance = nil
	ability.point = nil
end

function ApplyDistanceSlow(keys)
	local ability = keys.ability
	local distance = (keys.target:GetAbsOrigin() - keys.caster:GetAbsOrigin()):Length2D()
	local slow = math.abs(keys.ability:GetSpecialValueFor("max_slow")) * (keys.ability:GetCastRange()-distance) / keys.ability:GetCastRange()
	local maxdamage = keys.target:GetMaxHealth()*keys.ability:GetSpecialValueFor("max_damage_pct") / (10*100) -- tickrate is 10/s
	local mindamage = keys.target:GetMaxHealth()*keys.ability:GetSpecialValueFor("min_damage_pct") / (10*100)
	local damage = mindamage + ((maxdamage - mindamage) * (keys.ability:GetCastRange()-distance) / keys.ability:GetCastRange())
	ability:ApplyDataDrivenModifier(keys.caster, keys.target, keys.modifier, {duration = 0.5})
	keys.target:SetModifierStackCount(keys.modifier,keys.caster, slow)
	local damageamp = 1
	if keys.caster:HasAbility("new_game_damage_increase") then
		damageamp = keys.caster:GetSpellDamageAmp()
	end
	if not keys.target:IsMagicImmune() then
		ApplyDamage({victim = keys.target, attacker = keys.caster, damage = damage/damageamp, damage_type = keys.ability:GetAbilityDamageType(), ability = ability})
	end
end

function SlamWarning(keys)
	local caster = keys.caster
	local messageinfo = {
    message = "The Boss is channeling, stop him or run away!",
    duration = 2
    }
	FireGameEvent("show_center_message",messageinfo)
end
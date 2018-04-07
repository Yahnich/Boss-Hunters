function trueshot_initialize( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	local trueshot_modifier = keys.trueshot_modifier
	local trueshot_damage_modifier = keys.trueshot_damage_modifier

	-- Check if its a valid target
	if target and IsValidEntity(target) and target:HasModifier(trueshot_modifier) then
		local agility = caster:GetAgility()
		local percent = ability:GetTalentSpecialValueFor("trueshot_ranged_damage") 
		local trueshot_damage = math.floor(agility * percent / 100)

		-- If it doesnt have the stack modifier then apply it
		if not target:FindModifierByName(trueshot_damage_modifier) then
			ability:ApplyDataDrivenModifier(caster, target, trueshot_damage_modifier, {})
		end
		
		-- Set the damage to the calculated damage
		target:SetModifierStackCount(trueshot_damage_modifier, caster, trueshot_damage)
	end
end

function ResetAngles(keys)
	local caster = keys.caster
	local angles = caster:GetAnglesAsVector()
	caster:SetAngles(0, angles.y, angles.z)
end

function LeapShot( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1	

	-- Clears any current command and disjoints projectiles
	caster:Stop()
	ProjectileManager:ProjectileDodge(caster)
	
	local enemies = FindUnitsInRadius(caster:GetTeam(),
                                  caster:GetAbsOrigin(),
                                  nil,
                                  caster:GetAttackRange(),
                                  DOTA_UNIT_TARGET_TEAM_ENEMY,
                                  DOTA_UNIT_TARGET_ALL,
                                  DOTA_UNIT_TARGET_FLAG_NO_INVIS,
                                  FIND_ANY_ORDER,
                                  false)
	for _, enemy in pairs( enemies ) do
		caster:PerformAttack(enemy, true, true, true, false, false, false, true)
	end

	-- Ability variables
	ability.leap_direction = -(caster:GetAbsOrigin() - ability:GetCursorPosition()):Normalized()
	ability.leap_distance = ability:GetTalentSpecialValueFor("leap_distance")
	ability.leap_speed = ability:GetTalentSpecialValueFor("leap_speed") * 1/30
	ability.leap_traveled = 0
	ability.leap_z = 0
	local duration = ability.leap_distance / (ability.leap_speed * 30)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_leapshot_movement", {duration = duration})
end

--[[Moves the caster on the horizontal axis until it has traveled the distance]]
function LeapShotHorizonal( keys )
	local caster = keys.target
	local ability = keys.ability

	if ability.leap_traveled < ability.leap_distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.leap_direction * ability.leap_speed)
		ability.leap_traveled = ability.leap_traveled + ability.leap_speed
	else
		caster:RemoveModifierByName("modifier_leapshot_movement")
		caster:InterruptMotionControllers(true)
	end
end

--[[Moves the caster on the vertical axis until movement is interrupted]]
function LeapShotVertical( keys )
	local caster = keys.target
	local ability = keys.ability

	-- For the first half of the distance the unit goes up and for the second half it goes down
	if ability.leap_traveled < ability.leap_distance/2 then
		-- Go up
		-- This is to memorize the z point when it comes to cliffs and such although the division of speed by 2 isnt necessary, its more of a cosmetic thing
		ability.leap_z = ability.leap_z + ability.leap_speed/2
		-- Set the new location to the current ground location + the memorized z point
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
	else
		-- Go down
		ability.leap_z = ability.leap_z - ability.leap_speed/2
		caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
	end
end
function MoveUnits( keys )
	local caster = keys.caster
	local target = keys.target
	local target_location = target:GetAbsOrigin()
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	-- Takes note of the point entity, so we know what to remove the thinker from when the channel ends
	ability.point_entity = target
	
	-- Ability variables
	local radius = ability:GetLevelSpecialValueFor("radius", ability_level)
	local tick_rate = ability:GetLevelSpecialValueFor("tick_rate", ability_level)
	local damage = ability:GetAbilityDamage() * tick_rate

	-- Targeting variables
	local target_teams = ability:GetAbilityTargetTeam() 
	local target_types = ability:GetAbilityTargetType() 
	local target_flags = ability:GetAbilityTargetFlags() 

	-- Units to be caught in the black hole
	local units = FindUnitsInRadius(caster:GetTeamNumber(), target_location, nil, radius, target_teams, target_types, 0, 0, false)
	if not ability.units then ability.units = {} end

	-- Calculate the position of each found unit in relation to the center
	for i,unit in ipairs(units) do
		if not unit:HasModifier("modifier_enigma_black_hole_pull") and unit:HasMovementCapability() then
			if not ability.units[unit] then ability.units[unit] = true end		
			local unit_location = unit:GetAbsOrigin()
			local vector_distance = target_location - unit_location
			local distance = (vector_distance):Length2D()
			local speed = radius/distance * 10
			local direction = (vector_distance):Normalized()
			-- If the target is greater than 40 units from the center, we move them 40 units towards it, otherwise we move them directly to the center
			if distance <= radius then
				unit:SetAbsOrigin(unit_location - direction * speed)
				GridNav:DestroyTreesAroundPoint(unit:GetAbsOrigin(), unit:GetHullRadius(), true)
			end
			ApplyDamage({victim = unit, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType(), ability = ability})
		end
	end
end

--[[Author: YOLOSPAGHETTI
	Date: February 18, 2016
	Removes the thinker from the point entity and the sound from the caster when the channel ends]]
function ThinkerEnd(keys)
	local ability = keys.ability
	local caster = keys.caster
	
	if ability.point_entity:IsNull() == false then
		ability.point_entity:RemoveModifierByName("modifier_black_hole_datadriven")
		StopSoundOn("Hero_Enigma.Black_Hole", caster)
	end
	for unit, fuck in pairs(ability.units) do
		if not unit:IsNull() then
			FindClearSpaceForUnit(unit, unit:GetOrigin(), false)
			GridNav:DestroyTreesAroundPoint(unit:GetAbsOrigin(), unit:GetHullRadius()*2, false)
		end
	end
	ability.units = {}
end

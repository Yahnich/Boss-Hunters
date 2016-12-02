function ShieldInit(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local bounces = ability:GetLevelSpecialValueFor("bounces", (ability:GetLevel() -1))
	caster.bounces_left = bounces
	local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 9999, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), 0, 0, false)
		for _,unit in pairs(units) do
			unit.jumped = false
		end
end

function ShieldThrow(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local bounce_range = ability:GetLevelSpecialValueFor("bounce_range", (ability:GetLevel() -1))
	local bounce_delay = ability:GetLevelSpecialValueFor("bounce_delay", (ability:GetLevel() -1))
	local speed = ability:GetLevelSpecialValueFor("speed", (ability:GetLevel() -1))
	local duration = ability:GetLevelSpecialValueFor("duration", (ability:GetLevel() -1))
	local damage = ability:GetLevelSpecialValueFor("damage", (ability:GetLevel() -1))
	

	caster.bounces_left = caster.bounces_left - 1
	print(caster.bounces_left)
	-- Apply the stun to the current target
		target:AddNewModifier(target, ability, "modifier_stunned", {Duration = duration})
		ability:ApplyDataDrivenModifier(caster, target, "shield_daze", {})
		ApplyDamage({victim = target, attacker = caster, damage = damage, damage_type = ability:GetAbilityDamageType(), ability = ability})
	
	-- If the cask has bounces left, it finds a new target to bounce to
	if caster.bounces_left > 0 then
		-- We wait on the delay
		Timers:CreateTimer(bounce_delay,
		function()
			-- Finds all units in the area
			local units = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, bounce_range, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), 0, FIND_CLOSEST, false)
			-- Go through the target_enties table, checking for the first one that isn't the same as the target
			local target_to_jump = nil
			for _,unit in pairs(units) do
				if not unit.jumped then unit.jumped = false end
				if unit ~= target and not target_to_jump and unit.jumped == false then
					target_to_jump = unit
					unit.jumped = true
				elseif unit == target then
					unit.jumped = true
				end
			end
		
			-- If there is a new target to bounce to, we create the a projectile
			if target_to_jump then
				-- Create the next projectile
				local info = {
				Target = target_to_jump,
				Source = target,
				Ability = ability,
				EffectName = keys.particle,
				bDodgeable = true,
				bProvidesVision = false,
				iMoveSpeed = speed,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
				}
				ProjectileManager:CreateTrackingProjectile( info )
			else
				caster.bounces_left = nil
			end	
		end)
	else
		caster.bounces_left = nil
	end
end

function FreezeDamage(keys)
	ApplyDamage({victim = keys.target, attacker = keys.caster, damage = keys.ability:GetAbilityDamage(), damage_type = keys.ability:GetAbilityDamageType(), ability = keys.ability})
end

function StopFreezeSound(keys)
	StopSoundOn("Hero_Tusk.FrozenSigil", keys.caster)
end

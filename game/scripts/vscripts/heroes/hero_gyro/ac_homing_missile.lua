LinkLuaModifier( "modifier_movespeed_cap", "libraries/modifiers/modifier_movespeed_cap.lua" ,LUA_MODIFIER_MOTION_NONE )

function homingMissileCreate( keys )
	local caster = keys.caster
	local target = keys.target 
	local ability = keys.ability
	local fire = 0

	local missile_recharge_time = ability:GetLevelSpecialValueFor("missile_recharge_time", ability:GetLevel() -1)

	--create the missile and apply the restricted modifier
	local homingMissile = CreateUnitByName("npc_dota_gyrocopter_homing_missile",caster:GetAbsOrigin(),true,caster,caster:GetOwnerEntity(),caster:GetTeam())
	ability:StartCooldown(missile_recharge_time)
	ability:ApplyDataDrivenModifier(caster,homingMissile,"modifier_restricted",{})
	homingMissile:AddNewModifier(caster, nil, "modifier_movespeed_cap", {})
	
	--set the missile move speed to the targets move speed plus 100
	homingMissile:SetBaseMoveSpeed(340)

	EmitSoundOn("Hero_Gyrocopter.HomingMissile",homingMissile)
	
	--fuse particle
	local fuse = ParticleManager:CreateParticle(keys.particle, PATTACH_ABSORIGIN_FOLLOW, homingMissile) 
	ParticleManager:SetParticleControlEnt(fuse, 0, homingMissile, PATTACH_POINT_FOLLOW, "attach_hitloc", homingMissile:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(fuse, 1, homingMissile, PATTACH_POINT_FOLLOW, "attach_hitloc", homingMissile:GetAbsOrigin(), true)

	--annoying fix to keep the missile from hopping up, after a 1 second delay because of spawn animation
	Timers:CreateTimer(1.0, function()
		ability:ApplyDataDrivenModifier(caster,homingMissile,"modifier_frozen_fakie",{})
		return nil
	end)

	--after 2.5 seconds launch the missile to the target pos, updating every 0.1 seconds.
	--After hitting the enemy cause an explosion.
	Timers:CreateTimer(2.5, function()
		--remove the fuse just incase
		if fuse then
			ParticleManager:DestroyParticle(fuse,false)
		end

		--if the missile is alive. If the missile gets destoryed before reaching the target location, remove the fire particle
		if homingMissile:IsAlive() then
			--if we dont have the particles
			if fire == 0 then
				fire = ParticleManager:CreateParticle(keys.particle3, PATTACH_ABSORIGIN_FOLLOW, homingMissile) 
				ParticleManager:SetParticleControlEnt(fire, 0, homingMissile, PATTACH_POINT_FOLLOW, "attach_hitloc", homingMissile:GetAbsOrigin(), true)
				ParticleManager:SetParticleControlEnt(fire, 1, homingMissile, PATTACH_POINT_FOLLOW, "attach_hitloc", homingMissile:GetAbsOrigin(), true)
			end

			--removing the animation dummy holder
			if homingMissile:HasModifier("modifier_frozen_fakie") then
				homingMissile:RemoveModifierByName("modifier_frozen_fakie")
			end

			--if the target is alive otherwise forcekill
			if target:IsAlive() then
				--Move the missile to the target location
				homingMissile:MoveToPosition(target:GetAbsOrigin())
				homingMissile:SetBaseMoveSpeed(homingMissile:GetBaseMoveSpeed()+100)

				-- Find all nearby units
				nearbyUnits = FindUnitsInRadius(caster:GetTeam(),
                              homingMissile:GetAbsOrigin(),
                              nil,
                              150, --radius
                              DOTA_UNIT_TARGET_TEAM_ENEMY,
                              DOTA_UNIT_TARGET_ALL,
                              DOTA_UNIT_TARGET_FLAG_NONE,
                              FIND_ANY_ORDER,
                              false)
 
				--search around the missile to see if we are near the target
				for _,unit in pairs(nearbyUnits) do
  					if target == unit then
  						local explosion = ParticleManager:CreateParticle(keys.particle2, PATTACH_ABSORIGIN_FOLLOW, target) 
						ParticleManager:SetParticleControlEnt(explosion, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

						ParticleManager:DestroyParticle(fire,false)

						homingMissile:StopSound("Hero_Gyrocopter.HomingMissile")
						EmitSoundOn("Hero_Gyrocopter.HomingMissile.Destroy",homingMissile)
						homingMissile:AddNoDraw()
						homingMissile:ForceKill(false)
						return nil
  					end
				end
 	  			
 	  			--Checks to see if missile has reached destination, fail safe
 	  			if homingMissile:GetAbsOrigin() == target:GetAbsOrigin() and homingMissile:IsAlive() then
					local explosion = ParticleManager:CreateParticle(keys.particle2, PATTACH_ABSORIGIN_FOLLOW, target) 
					ParticleManager:SetParticleControlEnt(explosion, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

					ParticleManager:DestroyParticle(fire,false)

					homingMissile:StopSound("Hero_Gyrocopter.HomingMissile")
					homingMissile:AddNoDraw()
					homingMissile:ForceKill(false)
					return nil
				else
					return 0.1 --rerun interval
 	  			end--if end
			else
				ParticleManager:DestroyParticle(fire,false)
				homingMissile:StopSound("Hero_Gyrocopter.HomingMissile")
				homingMissile:AddNoDraw()
				homingMissile:ForceKill(false)
				return nil
			end
		else
			if fire then
				ParticleManager:DestroyParticle(fire,false)
			end
			return nil
		end		
	end)--timer, after 2.5 delay, 0.1 interval
end

function healthFun( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	caster:SetHealth( caster:GetHealth() - 1 )
end
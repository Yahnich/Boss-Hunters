function gatlingGun( keys )
	local caster = keys.caster
	local ability = keys.ability

	local range = ability:GetCastRange()
	local speed = caster:GetProjectileSpeed()

	Timers:CreateTimer(0, function()
		if caster:HasModifier("modifier_gatling_gun") then
			local forwardVec = caster:GetForwardVector()	
				forwardVec.x = forwardVec.x + RandomFloat(-0.25, 0.25)
				forwardVec.y = forwardVec.y + RandomFloat(-0.25, 0.25)
			local info = 
			{
				Ability = ability,
       			EffectName = "particles/units/heroes/hero_ac/ac_gatling_gun_projectile.vpcf",
       			vSpawnOrigin = caster:GetAbsOrigin() + Vector(0,0,150),
        		fDistance = range,
        		fStartRadius = 50,
        		fEndRadius = 50,
        		Source = caster,
        		bHasFrontalCone = false,
        		bReplaceExisting = false,
        		iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        		iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        		iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        		fExpireTime = GameRules:GetGameTime() + 10.0,
				bDeleteOnHit = false,
				vVelocity = Vector( forwardVec.x * speed, forwardVec.y * speed, 0 ),
				bProvidesVision = true,
				iVisionRadius = 1000,
				iVisionTeamNumber = caster:GetTeamNumber()
			}
			EmitSoundOn("Hero_Gyrocopter.FlackCannon",caster)
			projectile = ProjectileManager:CreateLinearProjectile(info)
			return 0.125
		else
			return nil
		end
	end)
end
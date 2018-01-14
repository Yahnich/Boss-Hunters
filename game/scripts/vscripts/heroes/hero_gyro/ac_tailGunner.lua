function tailGunner( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local max_projectiles = ability:GetLevelSpecialValueFor("max_projectiles", ability:GetLevel() -1)
	local recharge_rate = ability:GetLevelSpecialValueFor("recharge_rate", ability:GetLevel() -1)
	local currentProjectiles = 0

	ability:StartCooldown(recharge_rate)

	Timers:CreateTimer(0, function()
		if currentProjectiles < max_projectiles then
			local info = 
			{
				Target = target,
				Source = caster,
				Ability = ability,	
				EffectName = caster:GetRangedProjectileName(),
        		iMoveSpeed = caster:GetProjectileSpeed(),
				vSourceLoc= caster:GetAbsOrigin(),                -- Optional (HOW)
				bDrawsOnMinimap = false,                          -- Optional
       			bDodgeable = true,                                -- Optional
        		bIsAttack = false,                                -- Optional
        		bVisibleToEnemies = true,                         -- Optional
        		bReplaceExisting = true,                         -- Optional
        		flExpireTime = GameRules:GetGameTime() + 10,      -- Optional but recommended
				bProvidesVision = false,                           -- Optional
				iVisionRadius = 0,                              -- Optional
				iVisionTeamNumber = caster:GetTeamNumber()        -- Optional
			}
			local projectile = ProjectileManager:CreateTrackingProjectile(info)
			EmitSoundOn("Hero_Gyrocopter.FlackCannon",caster)
			currentProjectiles = currentProjectiles + 1
			return 0.25
		else
			return nil
		end
	end)
end

function damage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local max_projectiles = ability:GetLevelSpecialValueFor("max_projectiles", ability:GetLevel() -1)

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = caster:GetAttackDamage()/max_projectiles,
		damage_type = ability:GetAbilityDamageType(),
		damage_flags = ability:GetAbilityTargetFlags(), --Optional.
		ability = ability, --Optional.
	}
 
	ApplyDamage(damageTable)

end
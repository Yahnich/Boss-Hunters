function projectile_spear( keys )	
    local ability = keys.ability	
    local caster = keys.caster	
     local casterPoint = caster:GetAbsOrigin()	
    -- Spawn projectile	
    local projectileTable = {	
        Ability = ability,	
        EffectName = "particles/light_spear.vpcf",	
        vSpawnOrigin = casterPoint,	
        fDistance = 5000,	
        fStartRadius = 50,	
        fEndRadius = 50,	
        fExpireTime = GameRules:GetGameTime() + 5,	
        Source = caster,	
        bHasFrontalCone = true,	
        bReplaceExisting = false,	
        bProvidesVision = false,	
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,	
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,	
        bDeleteOnHit = false,	
        vVelocity = caster:GetForwardVector() * 600,	
        vAcceleration = caster:GetForwardVector() * 200	
    }	
    projectile = ProjectileManager:CreateLinearProjectile(projectileTable)	
end
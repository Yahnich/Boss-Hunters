sand_claw_impact = class({})
LinkLuaModifier( "modifier_caustics_enemy", "heroes/hero_sand/sand_caustics.lua" ,LUA_MODIFIER_MOTION_NONE )

function sand_claw_impact:PiercesDisableResistance()
    return true
end

function sand_claw_impact:OnSpellStart()
    local caster = self:GetCaster()

    local point = self:GetCursorPosition()

    if self:GetCursorTarget() then
        point = self:GetCursorTarget():GetAbsOrigin()
    end

    local direction = CalculateDirection(point, caster:GetAbsOrigin())
    local spawn_point = caster:GetAbsOrigin() + direction * self:GetTrueCastRange() 

    -- Set QAngles
    local left_QAngle = QAngle(0, 30, 0)
    local right_QAngle = QAngle(0, -30, 0)

    -- Left arrow variables
    local left_spawn_point = RotatePosition(caster:GetAbsOrigin(), left_QAngle, spawn_point)
    local left_direction = (left_spawn_point - caster:GetAbsOrigin()):Normalized()                

    -- Right arrow variables
    local right_spawn_point = RotatePosition(caster:GetAbsOrigin(), right_QAngle, spawn_point)
    local right_direction = (right_spawn_point - caster:GetAbsOrigin()):Normalized()        
                 
    self:SpikeLaunch(caster:GetForwardVector())
    self:SpikeLaunch(left_direction)
    self:SpikeLaunch(right_direction)
end

function sand_claw_impact:SpikeLaunch(direction)
    local caster = self:GetCaster()

    local info = 
    {
        Ability = self,
        EffectName = "particles/units/heroes/hero_lion/lion_spell_impale.vpcf",
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = self:GetTrueCastRange(),
        fStartRadius = 100,
        fEndRadius = 100,
        Source = caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + 10.0,
        bDeleteOnHit = true,
        vVelocity = direction * 1800 * Vector(1, 1, 0),
        bProvidesVision = true,
        iVisionRadius = 1000,
        iVisionTeamNumber = caster:GetTeamNumber()
    }
    ProjectileManager:CreateLinearProjectile(info)
end

function sand_claw_impact:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()

    if hTarget ~= nil then
        if not hTarget:HasModifier("modifier_knockback")  then
            local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lion/lion_spell_impale_hit_spikes.vpcf", PATTACH_POINT, caster)
            ParticleManager:SetParticleControl(nfx, 0, hTarget:GetAbsOrigin())
            ParticleManager:SetParticleControl(nfx, 1, hTarget:GetAbsOrigin())
            ParticleManager:SetParticleControl(nfx, 2, hTarget:GetAbsOrigin())

            hTarget:ApplyKnockBack(hTarget:GetAbsOrigin(), 0.5, 0.5, 0, 350, caster, self)

            Timers:CreateTimer(0.5,function()
                self:Stun(hTarget, self:GetTalentSpecialValueFor("duration"), false)
                self:DealDamage(caster, hTarget, self:GetTalentSpecialValueFor("damage"), {}, 0)

                if caster:HasTalent("special_bonus_unique_sand_claw_impact_2") then
                    local ability = caster:FindAbilityByName("sand_caustics")
                    hTarget:AddNewModifier(caster, ability, "modifier_caustics_enemy", {Duration = ability:GetTalentSpecialValueFor("duration")})
                end
            end)
        end
    end
end
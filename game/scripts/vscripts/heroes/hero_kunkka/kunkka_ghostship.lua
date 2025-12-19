kunkka_ghostship = class({})
--WHY IS YOUR DAMAGE SO INCONSISTENT
function kunkka_ghostship:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local fleet_interval = self:GetSpecialValueFor("fleet_interval")
    local fleet_count = self:GetSpecialValueFor("fleet_count")

    self:SummonShip(caster, point)
    
    if fleet_interval ~= 0 then
        Timers:CreateTimer(fleet_interval, function()
            fleet_count = fleet_count - 1
            self:SummonShip(caster,point)
            if fleet_count ~= 0 then
                return fleet_interval
            end
        end)
    else return
    end
end

function kunkka_ghostship:SummonShip(caster, location)
    local point = location
    local distance = self:GetSpecialValueFor("ghostship_distance")
    local width = self:GetSpecialValueFor("ghostship_width")
    local speed = self:GetSpecialValueFor("ghostship_speed")
    local ship_radius = self:GetSpecialValueFor("ship_radius")
    local cleave_radius = self:GetSpecialValueFor("tidebringer_cleave_radius")

    local damage = self:GetSpecialValueFor("damage")
    local stun_dur = self:GetSpecialValueFor("stun_duration")

    local dir = CalculateDirection(point, caster)
    dir.z = 0
    local proj_dir = dir:Normalized()

    local info =
    {
        EffectName = "particles/units/heroes/hero_kunkka/kunkka_ghost_ship.vpcf",
        Ability = self,
        vSpawnOrigin = point + dir * -distance,
        fStartRadius = ship_radius,
        fEndRadius = ship_radius,
        vVelocity = proj_dir * speed,
        fDistance = distance,
        Source = caster,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO,
    }

    ProjectileManager:CreateLinearProjectile(info)
    local marker = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_ghostship_marker.vpcf", PATTACH_POINT, caster)
                ParticleManager:SetParticleControl(marker, 0, point)
                ParticleManager:SetParticleControl(marker, 1, Vector(width, width, 0))
    EmitSoundOnLocationWithCaster(point, "Ability.Ghostship.bell", caster)
    EmitSoundOnLocationWithCaster(point, "Ability.Ghostship", caster)

    Timers:CreateTimer(self:GetSpecialValueFor("tooltip_delay"), function()
        ParticleManager:ClearParticle(marker)
        EmitSoundOnLocationWithCaster(point, "Ability.Ghostship.crash", caster)
        local enemies = caster:FindEnemyUnitsInRadius(point, width)
        local splash = caster:FindEnemyUnitsInRadius(point, cleave_radius)
        for _, enemy in ipairs(enemies) do
            self:DealDamage(caster, enemy, damage)
            self:Stun(enemy, stun_dur)
        end
        if cleave_radius ~= 0 then
            for _, extraUnit in ipairs(splash) do
                self:Tidebringer(caster, extraUnit)
            end
        end
    end)
end

function kunkka_ghostship:Tidebringer(source, target)
        local caster = self:GetCaster() or source
        local tidebringer = caster:FindAbilityByName("kunkka_tidebringer")
        if tidebringer then
            local baseDamage = caster:GetBaseDamageMax()
            local bonusDamage = self:GetSpecialValueFor("tidebringer_bonus_damage")
            local multiplier = self:GetSpecialValueFor("base_damage_multiplier") / 100
            local damage = (baseDamage + bonusDamage) * multiplier
            EmitSoundOn("Hero_Kunkka.TidebringerDamage", target)
            local tidebringer_hit_fx = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_spell_tidebringer.vpcf", PATTACH_CUSTOMORIGIN, caster)
                                    ParticleManager:SetParticleControlEnt(tidebringer_hit_fx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
                                    ParticleManager:SetParticleControlEnt(tidebringer_hit_fx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
                                    ParticleManager:SetParticleControl(tidebringer_hit_fx, 1, Vector(2,  17, 1))
                                    ParticleManager:SetParticleControlForward(tidebringer_hit_fx, 1, caster:GetForwardVector())
                                    ParticleManager:SetParticleControlEnt(tidebringer_hit_fx, 2, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
                                    ParticleManager:ReleaseParticleIndex(tidebringer_hit_fx)
            self:DealDamage(caster, target, damage / 4)
        else return
        end
end

function kunkka_ghostship:OnProjectileHit(hTarget)
    local rum_duration = self:GetSpecialValueFor("buff_duration")
    if hTarget ~= nil and rum_duration ~= 0 then
        local caster = self:GetCaster()
        local rum = caster:FindAbilityByName("kunkka_admirals_rum")
        if rum:IsTrained() then
            rum:Drink(hTarget, caster, rum_duration)
        else return
        end
    end
    return false
end
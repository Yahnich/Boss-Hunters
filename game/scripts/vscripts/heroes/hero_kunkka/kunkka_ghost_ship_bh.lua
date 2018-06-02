kunkka_ghost_ship_bh = class({})
LinkLuaModifier("modifier_kunkka_ghostship_rum", "heroes/hero_kunkka/kunkka_ghost_ship_bh.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_kunkka_ghostship_rum_damage", "heroes/hero_kunkka/kunkka_ghost_ship_bh.lua", LUA_MODIFIER_MOTION_NONE)

function kunkka_ghost_ship_bh:IsStealable()
    return true
end

function kunkka_ghost_ship_bh:IsHiddenWhenStolen()
    return false
end

function kunkka_ghost_ship_bh:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorPosition()

    local speed = self:GetTalentSpecialValueFor("speed")
    local radius = self:GetTalentSpecialValueFor("width")
    local start_distance = self:GetTalentSpecialValueFor("distance")/2
    local crash_distance = self:GetTalentSpecialValueFor("distance")/2 --CalculateDistance(target, caster:GetAbsOrigin())
    local caster_pos = caster:GetAbsOrigin()
    local totalDistance = start_distance + crash_distance

    local spawn_pos
    local boat_direction
    local crash_pos
    local travel_time

    -- Response on cast
    if caster:GetName() == "npc_dota_hero_kunkka" then
        caster:EmitSound("kunkka_kunk_ability_ghostshp_0"..math.random(1,3))
    end

    boat_direction = CalculateDirection(target, caster_pos)
    crash_pos = target
    spawn_pos = target + -boat_direction * totalDistance

    travel_time = totalDistance / speed         

    EmitSoundOnLocationWithCaster( spawn_pos, "Ability.Ghostship.bell", caster )
    EmitSoundOnLocationWithCaster( spawn_pos, "Ability.Ghostship", caster )

    self:SendShip(spawn_pos, totalDistance, radius, boat_direction, crash_pos, travel_time)

    if caster:HasTalent("special_bonus_unique_kunkka_ghost_ship_bh_1") then
        spawn_pos = caster:GetAbsOrigin() + caster:GetRightVector() * 250
        spawn_pos = spawn_pos + -boat_direction * totalDistance/2
        crash_pos = spawn_pos + boat_direction * totalDistance
        self:SendShip(spawn_pos, totalDistance, radius, boat_direction, crash_pos, travel_time)

        spawn_pos = caster:GetAbsOrigin() + -caster:GetRightVector() * 250
        spawn_pos = spawn_pos + -boat_direction * totalDistance/2
        crash_pos = spawn_pos + boat_direction * totalDistance
        self:SendShip(spawn_pos, totalDistance, radius, boat_direction, crash_pos, travel_time)
    end
end

function kunkka_ghost_ship_bh:SendShip(spawn_pos, totalDistance, radius, direction, crash_pos, travel_time)
    local caster = self:GetCaster()
    local speed = self:GetTalentSpecialValueFor("speed")

    self:CreateVisibilityNode(crash_pos, radius, travel_time + 2 )

    local boat_projectile = {
        Ability = self,
        EffectName = "particles/units/heroes/hero_kunkka/kunkka_ghost_ship.vpcf",
        vSpawnOrigin = spawn_pos,
        fDistance = totalDistance,
        fStartRadius = radius,
        fEndRadius = radius,
        fExpireTime = GameRules:GetGameTime() + travel_time + 2,
        Source = caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        bProvidesVision = false,
        iUnitTargetTeam = self:GetAbilityTargetTeam(),
        iUnitTargetType = self:GetAbilityTargetType(),
        vVelocity = direction * speed,
    }
    ProjectileManager:CreateLinearProjectile(boat_projectile)

    -- Show visual crash point effect to allies only
    local crash_pfx = ParticleManager:CreateParticleForTeam("particles/units/heroes/hero_kunkka/kunkka_ghostship_marker.vpcf", PATTACH_POINT, caster, caster:GetTeam())
    ParticleManager:SetParticleControl(crash_pfx, 0, crash_pos )
    -- Destroy particle after the crash
    Timers:CreateTimer(travel_time, function()
        ParticleManager:DestroyParticle(crash_pfx, false)
        ParticleManager:ReleaseParticleIndex(crash_pfx)

        -- Fire sound on crash point
        EmitSoundOnLocationWithCaster(crash_pos, "Ability.Ghostship.crash", caster)

        -- Stun and damage enemies
        local enemies = caster:FindEnemyUnitsInRadius(crash_pos, radius)
        if (not (#enemies > 0)) and (caster:GetName() == "npc_dota_hero_kunkka") then
            if math.random(1,2) == 1 then
                caster:EmitSound("kunkka_kunk_ability_failure_0"..math.random(1,2))
            end
        end
        for _, enemy in pairs(enemies) do
            self:Stun(enemy, self:GetTalentSpecialValueFor("stun_duration"), false)
            self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
        end
    end)
end

function kunkka_ghost_ship_bh:OnProjectileThink(vLocation)
    local caster = self:GetCaster()
    if caster:HasTalent("special_bonus_unique_kunkka_ghost_ship_bh_2") then
        local enemies = caster:FindEnemyUnitsInRadius(vLocation, self:GetSpecialValueFor("width"))
        for _,enemy in pairs(enemies) do
            enemy:SetAbsOrigin(vLocation)
        end
    end
end

function kunkka_ghost_ship_bh:OnProjectileHit(target, location)
    if target then
        if self:GetCaster():GetTeam() == target:GetTeam() then
            target:AddNewModifier(self:GetCaster(), self, "modifier_kunkka_ghostship_rum", { duration = self:GetTalentSpecialValueFor("duration") })
        end
    else
        if self:GetCaster():HasTalent("special_bonus_unique_kunkka_ghost_ship_bh_2") then
            local enemies = self:GetCaster():FindEnemyUnitsInRadius(location, self:GetSpecialValueFor("width"))
            for _,enemy in pairs(enemies) do
                FindClearSpaceForUnit(enemy, location, true)
            end
        end
    end
    return false
end

modifier_kunkka_ghostship_rum = class({})

function modifier_kunkka_ghostship_rum:GetModifierMoveSpeedBonus_Percentage()
    return self:GetTalentSpecialValueFor("movespeed_bonus")
end

-- Setting up the damage counter
function modifier_kunkka_ghostship_rum:OnCreated()
    if IsServer() then
        self.damage_counter = 0
    end
end

function modifier_kunkka_ghostship_rum:GetModifierIncomingDamage_Percentage()
    return self:GetTalentSpecialValueFor("absorb")
end

function modifier_kunkka_ghostship_rum:DeclareFunctions()
    local decFuncs =
        {
            MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
            MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
            MODIFIER_EVENT_ON_TAKEDAMAGE,
        }
    return decFuncs
end

function modifier_kunkka_ghostship_rum:OnTakeDamage( params )
    if IsServer() then
        if params.unit == self:GetParent() then
            local rum_reduction = (100 - self:GetTalentSpecialValueFor("absorb"))/100
            local prevented_damage = params.damage / rum_reduction - params.damage

            self.damage_counter = self.damage_counter + prevented_damage
        end
    end
end

function modifier_kunkka_ghostship_rum:OnDestroy()
    if IsServer() then
        local caster = self:GetCaster()
        local ability = self:GetAbility()
        self:GetParent():AddNewModifier(caster, ability, "modifier_kunkka_ghostship_rum_damage", { duration = self:GetTalentSpecialValueFor("duration"), stored_damage = self.damage_counter })
        self.damage_counter = 0
    end
end

function modifier_kunkka_ghostship_rum:GetStatusEffectName()
    return "particles/status_fx/status_effect_rum.vpcf"
end

function modifier_kunkka_ghostship_rum:StatusEffectPriority()
    return 10
end

function modifier_kunkka_ghostship_rum:GetTexture()
    return "kunkka_ghostship"
end

function modifier_kunkka_ghostship_rum:IsHidden()
    return false
end

function modifier_kunkka_ghostship_rum:IsPurgable()
    return false
end

function modifier_kunkka_ghostship_rum:IsDebuff( )
    return false
end

modifier_kunkka_ghostship_rum_damage = class({})
function modifier_kunkka_ghostship_rum_damage:IsHidden()
    return false
end

function modifier_kunkka_ghostship_rum_damage:GetTexture()
    return "kunkka_ghostship"
end

function modifier_kunkka_ghostship_rum_damage:IsPurgable()
    return false
end

function modifier_kunkka_ghostship_rum_damage:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_kunkka_ghostship_rum_damage:IsDebuff( )
    return true
end

function modifier_kunkka_ghostship_rum_damage:OnCreated( params )
    if IsServer() then
        local ability = self:GetAbility()
        local parent = self:GetParent()

        local damage_duration = self:GetTalentSpecialValueFor("duration")
        local damage_interval = 1
        local ticks = damage_duration / damage_interval
        local damage_amount = params.stored_damage / ticks
        local current_tick = 0

        Timers:CreateTimer(damage_interval, function()
            -- If the target has died, do nothing
            if parent:IsAlive() then

                -- Nonlethal HP removal
                local target_hp = parent:GetHealth()
                if target_hp - damage_amount < 1 then
                    parent:SetHealth(1)
                else
                    parent:SetHealth(target_hp - damage_amount)
                end

                current_tick = current_tick + 1
                if current_tick >= ticks then
                    return nil
                else
                    return damage_interval
                end
            else
                return nil
            end
        end)
    end
end
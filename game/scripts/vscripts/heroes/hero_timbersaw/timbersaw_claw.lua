timbersaw_claw = class({})
LinkLuaModifier( "modifier_timbersaw_claw_pull", "heroes/hero_timbersaw/timbersaw_claw.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_timbersaw_hylophobia", "heroes/hero_timbersaw/timbersaw_hylophobia.lua" ,LUA_MODIFIER_MOTION_NONE )

function timbersaw_claw:IsStealable()
    return true
end

function timbersaw_claw:IsHiddenWhenStolen()
    return false
end

function timbersaw_claw:GetCastRange(vLocation, hTarget)
    return self:GetTalentSpecialValueFor("distance")
end

function timbersaw_claw:PiercesDisableResistance()
    return true
end

function timbersaw_claw:OnSpellStart()
    local caster = self:GetCaster()

    EmitSoundOn("Hero_Shredder.TimberChain.Cast", caster)

    -- Set the global hook_launched variable
    self.hook_launched = true
    
    -- Parameters
    local hook_speed = self:GetTalentSpecialValueFor("speed")
    local hook_width = self:GetTalentSpecialValueFor("width")
    local hook_range = self:GetTrueCastRange()
    local hook_damage = self:GetTalentSpecialValueFor("damage")
    local caster_loc = caster:GetAbsOrigin()
    local start_loc = caster_loc + CalculateDirection(self:GetCursorPosition(), caster_loc) * hook_range

    -- Create and set up the Hook dummy unit
    self.hook_dummy = caster:CreateDummy(caster_loc)
    self.hook_dummy:SetForwardVector(caster:GetForwardVector())
    
    -- Attach the Hook particle
    self.hook_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_shredder/shredder_timberchain.vpcf", PATTACH_POINT_FOLLOW, caster)
    ParticleManager:SetParticleAlwaysSimulate(self.hook_pfx)
    ParticleManager:SetParticleControlEnt(self.hook_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster_loc, true)
    ParticleManager:SetParticleControlEnt(self.hook_pfx, 1, self.hook_dummy, PATTACH_POINT_FOLLOW, "attach_hitloc", self.hook_dummy:GetAbsOrigin(), false)
    ParticleManager:SetParticleControl(self.hook_pfx, 2, Vector(hook_speed, hook_range, hook_width) )
    ParticleManager:SetParticleControl(self.hook_pfx, 3, Vector(60, 60, 60) )
    --ParticleManager:SetParticleControlEnt(self.hook_pfx, 7, caster, PATTACH_CUSTOMORIGIN, nil, caster_loc, true)

    -- Initialize Hook variables
    local hook_loc = self.hook_dummy:GetAbsOrigin()
    local tick_rate = 0.03
    hook_speed = hook_speed * tick_rate

    local travel_distance = CalculateDistance(hook_loc, caster_loc)
    local hook_step = CalculateDirection(self:GetCursorPosition(), caster_loc) * hook_speed

    local target_hit = false
    local target

    -- Main Hook loop
    Timers:CreateTimer(0, function()
        -- Check for valid units in the area
        local enemies = caster:FindEnemyUnitsInRadius(hook_loc, hook_width, {})
        for _,enemy in pairs(enemies) do
            if enemy ~= caster and enemy ~= self.hook_dummy and (not enemy:IsKnockedBack() or not enemy:IsStunned())  then
                --target_hit = true
                --target = enemy
                local hook_pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
                ParticleManager:ReleaseParticleIndex(hook_pfx2)
                if caster:HasTalent("special_bonus_unique_timbersaw_claw_2") then
                    self:Stun(enemy, caster:FindTalentValue("special_bonus_unique_timbersaw_claw_2"), false)
                else
                    enemy:ApplyKnockBack(caster_loc, 0.5, 0.5, self:GetTalentSpecialValueFor("knockback"), 100, caster, self)
                end

                self:DealDamage(caster, enemy, hook_damage, {}, 0)
            end
        end

        if caster:HasTalent("special_bonus_unique_timbersaw_claw_1") then
            local trees = GridNav:GetAllTreesAroundPoint(hook_loc, hook_width/2, false)
            if #trees > 0 then
                for _,tree in pairs(trees) do
                    self.hook_dummy:SetAbsOrigin(tree:GetAbsOrigin())
                    caster:AddNewModifier(caster, self, "modifier_timbersaw_claw_pull", {})
                    
                    return nil
                end
            end
        end

        if travel_distance < hook_range then
            -- Move the hook
            self.hook_dummy:SetAbsOrigin(hook_loc + hook_step)

            -- Recalculate position and distance
            hook_loc = self.hook_dummy:GetAbsOrigin()
            travel_distance = CalculateDistance(hook_loc, caster_loc)
            --hook_speed = math.max(hook_speed, 5000 * tick_rate)
            if not caster:HasTalent("special_bonus_unique_timbersaw_claw_1") then
                local treesCut = CutTreesInRadius(hook_loc, hook_width)
                if treesCut > 0 then
                    local duration = caster:FindAbilityByName("timbersaw_hylophobia"):GetSpecialValueFor("duration")
                    for i=1,treesCut do
                        caster:AddNewModifier(caster, caster:FindAbilityByName("timbersaw_hylophobia"), "modifier_timbersaw_hylophobia", {Duration = duration}):AddIndependentStack(duration)
                    end
                end
            end

            return tick_rate
        end

        

        -- If we are here, this means the hook has to start reeling back; prepare return variables
        local direction = ( caster_loc - hook_loc )
        local current_tick = 0

        -- Hook reeling loop
        Timers:CreateTimer(0, function()

            -- Recalculate position variables
            caster_loc = caster:GetAbsOrigin()
            hook_loc = self.hook_dummy:GetAbsOrigin()
            direction = ( caster_loc - hook_loc )
            hook_step = direction:Normalized() * hook_speed
            --current_tick = current_tick + 1
            local treesCut = CutTreesInRadius(hook_loc, hook_width)
            if treesCut > 0 then
                local duration = caster:FindAbilityByName("timbersaw_hylophobia"):GetTalentSpecialValueFor("duration")
                for i=1,treesCut do
                    caster:AddNewModifier(caster, caster:FindAbilityByName("timbersaw_hylophobia"), "modifier_timbersaw_hylophobia", {Duration = duration}):AddIndependentStack(duration)
                end
            end

            local enemies = caster:FindEnemyUnitsInRadius(hook_loc, hook_width, {})
            for _,enemy in pairs(enemies) do
                if enemy ~= caster and enemy ~= self.hook_dummy and not enemy:IsKnockedBack() then
                    --target_hit = true
                    --target = enemy
                    EmitSoundOn("Hero_Shredder.TimberChain.Damage", enemy)
                    enemy:ApplyKnockBack(caster_loc, 0.5, 0.5, -self:GetTalentSpecialValueFor("knockback"), 100, caster, self)
                    self:DealDamage(caster, enemy, hook_damage, {}, 0)
                    break
                end
            end
            current_tick = current_tick + 1
            -- If the target is close enough, or the hook has been out too long, finalize the hook return
            if direction:Length2D() < 100 or current_tick > 300 then
                EmitSoundOn("Hero_Shredder.TimberChain.Impact", caster)
                -- Destroy the hook dummy and particles
                self.hook_dummy:Destroy()
                ParticleManager:DestroyParticle(self.hook_pfx, false)              

                -- Clear global variables
                self.hook_launched = false

            -- If this is not the final step, keep reeling the hook in
            else
                -- Move the hook and an eventual target
                self.hook_dummy:SetAbsOrigin(hook_loc + hook_step)
                ParticleManager:SetParticleControlEnt(self.hook_pfx, 1, self.hook_dummy, PATTACH_POINT_FOLLOW, "attach_hitloc", self.hook_dummy:GetAbsOrigin(), false)
                --ParticleManager:SetParticleControl(self.hook_pfx, 1, self.hook_dummy:GetAbsOrigin())
                
                return tick_rate
            end
        end)
    end)
end

modifier_timbersaw_claw_pull = class({})
function modifier_timbersaw_claw_pull:OnCreated(table)
    if IsServer() then
        local parent = self:GetParent()
        local target = self:GetAbility().hook_dummy

        self.distance = CalculateDistance(target, parent)
        self.dir = CalculateDirection(target, parent)
        self:StartIntervalThink(FrameTime())
        self:StartMotionController()
    end
end

function modifier_timbersaw_claw_pull:OnIntervalThink()
    local parent = self:GetParent()
    local enemies = parent:FindEnemyUnitsInRadius(parent:GetAbsOrigin(),225)
    for _,enemy in pairs(enemies) do
        if not enemy:IsKnockedBack() then
            EmitSoundOn("Hero_Shredder.TimberChain.Damage", enemy)
            enemy:ApplyKnockBack(parent:GetAbsOrigin(), 0.5, 0.5, -self:GetTalentSpecialValueFor("knockback"), 100, parent, self)
            self:GetAbility():DealDamage(parent, enemy, self:GetSpecialValueFor("damage"), {}, 0)
        end
    end
end

function modifier_timbersaw_claw_pull:DoControlledMotion()
    local parent = self:GetParent()

    if self.distance > 0 then
        self.distance = self.distance - 100
        --GridNav:DestroyTreesAroundPoint(parent:GetAbsOrigin(), self:GetTalentSpecialValueFor("width"), true)
        parent:SetAbsOrigin(GetGroundPosition(parent:GetAbsOrigin(), parent) + self.dir*100)

        local treesCut = CutTreesInRadius(parent:GetAbsOrigin(), 225)
        if treesCut > 0 then
            local duration = parent:FindAbilityByName("timbersaw_hylophobia"):GetTalentSpecialValueFor("duration")
            for i=1,treesCut do
                parent:AddNewModifier(parent, parent:FindAbilityByName("timbersaw_hylophobia"), "modifier_timbersaw_hylophobia", {Duration = duration}):AddIndependentStack(duration)
            end
        end
    else
        FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)

        ParticleManager:DestroyParticle(self:GetAbility().hook_pfx, false)

        self:StopMotionController(true)
    end
end

function modifier_timbersaw_claw_pull:CheckState()
    local state = { [MODIFIER_STATE_DISARMED] = true,
                    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                    [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
    return state
end
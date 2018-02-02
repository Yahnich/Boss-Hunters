tide_tongue_whip = class({})
LinkLuaModifier( "modifier_tongue_whip", "heroes/hero_tide/tide_tongue_whip.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_tongue_whip_health", "heroes/hero_tide/tide_tongue_whip.lua" ,LUA_MODIFIER_MOTION_NONE )

function tide_tongue_whip:GetCastRange(vLocation, hTarget)
    return self:GetTalentSpecialValueFor("distance")
end

function tide_tongue_whip:PiercesDisableResistance()
    return true
end

function tide_tongue_whip:OnSpellStart()
    local caster = self:GetCaster()

    -- Set the global hook_launched variable
    self.hook_launched = true
    
    -- Parameters
    local hook_speed = self:GetTalentSpecialValueFor("speed")
    local hook_width = self:GetTalentSpecialValueFor("width")
    local hook_range = self:GetTrueCastRange()
    local hook_damage = self:GetTalentSpecialValueFor("damage")
    local caster_loc = caster:GetAbsOrigin()
    local start_loc = caster_loc + ((self:GetCursorPosition() - caster_loc) * Vector(1,1,0)):Normalized() * hook_width

    -- Create and set up the Hook dummy unit
    local hook_dummy = CreateUnitByName("npc_dummy_blank", start_loc + Vector(0, 0, 150), false, caster, caster, caster:GetTeam())
    hook_dummy:AddAbility("hide_hero"):SetLevel(1)
    hook_dummy:SetForwardVector(caster:GetForwardVector())
    
    -- Attach the Hook particle
    local hook_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tide/tide_tongue_whip/tide_tongue_whip_b.vpcf", PATTACH_POINT_FOLLOW, caster)
    ParticleManager:SetParticleAlwaysSimulate(hook_pfx)
    ParticleManager:SetParticleControlEnt(hook_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster_loc, true)
    ParticleManager:SetParticleControlEnt(hook_pfx, 3, hook_dummy, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", start_loc, false)

    -- Initialize Hook variables
    local hook_loc = start_loc
    local tick_rate = FrameTime()
    hook_speed = hook_speed * tick_rate

    local travel_distance = (hook_loc - caster_loc):Length2D()
    local hook_step = ((self:GetCursorPosition() - caster_loc) * Vector(1,1,0)):Normalized() * hook_speed

    local target_hit = false
    local target

    local eat = false

    -- Main Hook loop
    Timers:CreateTimer(tick_rate, function()
        -- Check for valid units in the area
        local enemies = caster:FindEnemyUnitsInRadius(hook_loc, hook_width, {})
        for _,enemy in pairs(enemies) do
            if enemy ~= caster and enemy ~= hook_dummy then
                target_hit = true
                target = enemy
                if target:GetHealthPercent() <= self:GetTalentSpecialValueFor("eat_threshold") then
                    eat = true
                end

                if caster:HasTalent("special_bonus_unique_tide_tongue_whip_2") then
                    local enemies3 = caster:FindEnemyUnitsInRadius(hook_loc, hook_width, {})
                    for _,enemy2 in pairs(enemies) do
                        if enemy2 ~= enemy and not enemy2:HasModifier("modifier_knockback") then
                            enemy2:ApplyKnockBack(enemy:GetAbsOrigin(), 0.5, 0.5, 250, 50, caster, self)
                        end
                    end
                end
                break
            end
        end

        -- If a valid target was hit, start dragging them
        if target_hit then
            self:DealDamage(caster, target, hook_damage, {}, 0)
            caster:ModifyThreat(self:GetTalentSpecialValueFor("threat_gain"))

            local hook_pfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_meathook_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
            ParticleManager:ReleaseParticleIndex(hook_pfx2)

            if not target:IsAlive() then
                caster:AddNewModifier(caster, self, "modifier_tongue_whip_health", {}):IncrementStackCount()
                caster:CalculateStatBonus()
            end

            hook_speed = math.max(hook_speed, 5000 * tick_rate)
        elseif travel_distance < hook_range then
            -- Move the hook
            hook_dummy:SetAbsOrigin(hook_loc + hook_step)

            -- Recalculate position and distance
            hook_loc = hook_dummy:GetAbsOrigin()
            travel_distance = (hook_loc - caster_loc):Length2D()
            hook_speed = math.max(hook_speed, 5000 * tick_rate)
            return tick_rate
        end

        -- If we are here, this means the hook has to start reeling back; prepare return variables
        local direction = ( caster_loc - hook_loc )
        local current_tick = 0

        -- Hook reeling loop
        Timers:CreateTimer(tick_rate, function()

            -- Recalculate position variables
            caster_loc = caster:GetAbsOrigin()
            hook_loc = hook_dummy:GetAbsOrigin()
            direction = ( caster_loc - hook_loc )
            hook_step = direction:Normalized() * hook_speed
            current_tick = current_tick + 1
            
            -- If the target is close enough, or the hook has been out too long, finalize the hook return
            if direction:Length2D() < hook_speed or current_tick > 300 then

                -- Stop moving the target
                if target_hit and eat then
                    local final_loc = caster_loc + caster:GetForwardVector() * 100
                    FindClearSpaceForUnit(target, final_loc, false)

                    -- Remove the target's modifiers
                    target:RemoveModifierByName("modifier_tongue_whip")
                    target:ForceKill(false)
					if target:AttemptKill(self, caster) then
						caster:AddNewModifier(caster, self, "modifier_tongue_whip_health", {}):IncrementStackCount()
						caster:CalculateStatBonus()
					end
                elseif target_hit and caster:HasTalent("special_bonus_unique_tide_tongue_whip_1") then
                    local final_loc = caster_loc + caster:GetForwardVector() * 100
                    FindClearSpaceForUnit(target, final_loc, false)

                    -- Remove the target's modifiers
                    target:RemoveModifierByName("modifier_tongue_whip")
                end

                -- Destroy the hook dummy and particles
                hook_dummy:Destroy()
                ParticleManager:DestroyParticle(hook_pfx, false)              

                -- Clear global variables
                self.hook_launched = false

            -- If this is not the final step, keep reeling the hook in
            else

                -- Move the hook and an eventual target
                hook_dummy:SetAbsOrigin(hook_loc + hook_step)
                ParticleManager:SetParticleControl(hook_pfx, 6, hook_loc + hook_step + Vector(0, 0, 90))

                if target_hit and eat then
                    target:SetAbsOrigin(hook_loc + hook_step)
                    target:SetForwardVector(direction:Normalized())
                elseif target_hit and caster:HasTalent("special_bonus_unique_tide_tongue_whip_1") then
                    target:SetAbsOrigin(hook_loc + hook_step)
                    target:SetForwardVector(direction:Normalized())
                end
                
                return tick_rate
            end
        end)
    end)
end

modifier_tongue_whip = class({})
function modifier_tongue_whip:IsHidden()
    return true
end

function modifier_tongue_whip:IsStunDebuff()
    return true
end

function modifier_tongue_whip:DeclareFunctions()
    local funcs = { MODIFIER_PROPERTY_OVERRIDE_ANIMATION }
    return funcs
end

function modifier_tongue_whip:GetOverrideAnimation( params )
    return ACT_DOTA_FLAIL
end

function modifier_tongue_whip:CheckState()
    local state = {[MODIFIER_STATE_STUNNED] = true}
    return state
end

modifier_tongue_whip_health = class({})
function modifier_tongue_whip_health:DeclareFunctions()
    funcs = { MODIFIER_PROPERTY_HEALTH_BONUS }
    return funcs
end

function modifier_tongue_whip_health:OnCreated()
	self.bonus_hp = self:GetTalentSpecialValueFor("eat_health")
end

function modifier_tongue_whip_health:OnRefresh()
	self.bonus_hp = self:GetTalentSpecialValueFor("eat_health")
end

function modifier_tongue_whip_health:GetModifierHealthBonus()
    return self.bonus_hp * self:GetStackCount()
end

function modifier_tongue_whip_health:RemoveOnDeath()
	return false
end

function modifier_tongue_whip_health:IsPermanent()
	return true
end

function modifier_tongue_whip_health:IsPurgable()
	return false
end
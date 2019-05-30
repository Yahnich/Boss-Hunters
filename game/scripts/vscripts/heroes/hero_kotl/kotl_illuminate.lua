kotl_illuminate = class({})
LinkLuaModifier( "modifier_kotl_illuminate", "heroes/hero_kotl/kotl_illuminate.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kotl_illuminate_spirit", "heroes/hero_kotl/kotl_illuminate.lua" ,LUA_MODIFIER_MOTION_NONE )

function kotl_illuminate:IsStealable()
    return true
end

function kotl_illuminate:IsHiddenWhenStolen()
    return false
end

function kotl_illuminate:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_kotl_illuminate") then
        return "keeper_of_the_light_illuminate_end"
    end

    if self:GetCaster():HasScepter() then
        return "keeper_of_the_light_spirit_form_illuminate"
    end

    return "keeper_of_the_light_illuminate"
end

function kotl_illuminate:GetBehavior()
    if self:GetCaster():HasModifier("modifier_kotl_illuminate") then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET
    end

    if self:GetCaster():HasScepter() then
        return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_DIRECTIONAL
    end

    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_CHANNELLED + DOTA_ABILITY_BEHAVIOR_DIRECTIONAL
end

function kotl_illuminate:GetChannelTime()
    if self:GetCaster():HasScepter() or self:GetCaster():HasModifier("modifier_kotl_illuminate") then
        return 0
    end

    return self:GetTalentSpecialValueFor("max_channel")
end

function kotl_illuminate:GetChannelAnimation()
    return "ACT_DOTA_CAST_ABILITY_1"
end

function kotl_illuminate:OnSpellStart()
    local caster = self:GetCaster()
    
    EmitSoundOn("Hero_KeeperOfTheLight.Illuminate.Charge", caster)

    if caster:HasModifier("modifier_kotl_illuminate") then
        EmitSoundOn("Hero_KeeperOfTheLight.Illuminate.Discharge", caster)
        StopSoundOn("Hero_KeeperOfTheLight.Illuminate.Charge", caster)
        self:StartCooldown(self:GetTrueCooldown())
        self:RefundManaCost()
        caster:RemoveModifierByName("modifier_kotl_illuminate")
    else
        if caster:HasScepter() then
            local point = self:GetCursorPosition()
            self.dir = CalculateDirection(point, caster:GetAbsOrigin())

            self.castPoint = caster:GetAbsOrigin()

            self:EndCooldown()
            caster:AddNewModifier(caster, self, "modifier_kotl_illuminate", {Duration = self:GetTalentSpecialValueFor("max_channel")})

            self.spirit = caster:CreateSummon("npc_kotl_spirit", caster:GetAbsOrigin(), self:GetTalentSpecialValueFor("max_channel"))
            self.spirit:AddNewModifier(caster, self, "modifier_kotl_illuminate_spirit", {})
            self.spirit:StartGesture(ACT_DOTA_CAST_ABILITY_1)
            self.spirit:SetForwardVector(self.dir)

            self.castNfx2 = ParticleManager:CreateParticle("particles/units/heroes/hero_kotl/kotl_illuminate_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
            ParticleManager:SetParticleControlEnt(self.castNfx2, 0, self.spirit, PATTACH_POINT_FOLLOW, "attach_attack1", self.spirit:GetAbsOrigin(), true)

            self.count = 0

            Timers:CreateTimer(FrameTime(), function()
                if caster:HasModifier("modifier_kotl_illuminate") then
                    self.count = self.count + 1
                    return 0.5
                else
                    EmitSoundOn("Hero_KeeperOfTheLight.Illuminate.Discharge", caster)
                    StopSoundOn("Hero_KeeperOfTheLight.Illuminate.Charge", caster)
                    ParticleManager:DestroyParticle(self.castNfx2, false)
                    caster:RemoveModifierByName("modifier_kotl_illuminate")
                    self:LaunchHorses(self.spirit, self.spirit:GetAbsOrigin(), self.spirit:GetForwardVector())
                    self:StartCooldown(self:GetTrueCooldown())
                    self.spirit:StartGesture(ACT_DOTA_CAST_ABILITY_1_END)
                    self.spirit:AddNoDraw()
                    self.spirit:ForceKill(false)
                    return nil
                end
            end)
        else
            if self:IsChanneling() then
                EmitSoundOn("Hero_KeeperOfTheLight.Illuminate.Discharge", caster)
                StopSoundOn("Hero_KeeperOfTheLight.Illuminate.Charge", caster)
                self:StartCooldown(self:GetTrueCooldown())
                self:RefundManaCost()
                self:EndChannel(true)
            else
                local point = self:GetCursorPosition()
                self.dir = CalculateDirection(point, caster:GetAbsOrigin())

                self.castPoint = caster:GetAbsOrigin()
                --self:EndCooldown()
                self.castNfx = ParticleManager:CreateParticle("particles/units/heroes/hero_kotl/kotl_illuminate_cast.vpcf", PATTACH_POINT_FOLLOW, caster)
                ParticleManager:SetParticleControlEnt(self.castNfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)

                self.count = 0

                Timers:CreateTimer(FrameTime(), function()
                    if self:IsChanneling() then
                        self.count = self.count + 1
                        return 0.5
                    else
                        EmitSoundOn("Hero_KeeperOfTheLight.Illuminate.Discharge", caster)
                        StopSoundOn("Hero_KeeperOfTheLight.Illuminate.Charge", caster)
                        return nil
                    end
                end)
            end
        end
    end
end

function kotl_illuminate:OnChannelFinish(bInterrupted)
    local caster = self:GetCaster()

    EmitSoundOn("Hero_KeeperOfTheLight.Illuminate.Discharge", caster)
    StopSoundOn("Hero_KeeperOfTheLight.Illuminate.Charge", caster)
    self:LaunchHorses(caster, caster:GetAbsOrigin(), CalculateDirection(self:GetCursorPosition(), caster:GetAbsOrigin()))
    caster:StartGesture(ACT_DOTA_CAST_ABILITY_1_END)

end

function kotl_illuminate:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()

    if hTarget then
        local damage = self:GetTalentSpecialValueFor("damage_per_horse")

        if hTarget:GetTeam() ~= caster:GetTeam() then
            EmitSoundOn("Hero_KeeperOfTheLight.Illuminate.Target", hTarget)
            ParticleManager:FireParticle("particles/units/heroes/hero_keeper_of_the_light/kotl_illuminate_impact_hero.vpcf", PATTACH_POINT, hTarget, {})
            
            if caster:HasTalent("special_bonus_unique_kotl_illuminate_2") then
                local duration = caster:FindTalentValue("special_bonus_unique_kotl_illuminate_2")
                hTarget:Daze(self, caster, duration)
            end

            self:DealDamage(caster, hTarget, self:GetTalentSpecialValueFor("damage_per_horse"), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)

        else
            if caster:HasTalent("special_bonus_unique_kotl_illuminate_1") then

                EmitSoundOn("Hero_KeeperOfTheLight.Illuminate.Target.Secondary", hTarget)
                hTarget:HealEvent(damage, self, caster)
            end
        end
    end
end

function kotl_illuminate:LaunchHorses(hCaster, vLocation, direction)
    local caster = hCaster

    local spawn_point = vLocation

    local speed = self:GetTalentSpecialValueFor("speed")
    local radius = self:GetTalentSpecialValueFor("radius")
    local distance = self:GetTrueCastRange()

    local firstHorse = spawn_point + direction * 150
    local vel = direction * speed

    local left_1_Point = spawn_point - caster:GetRightVector() * 100
    local left_1_vel = GetPerpendicularVector( CalculateDirection(left_1_Point, vLocation) ) * speed

    local left_2_Point = spawn_point - caster:GetRightVector() * 200
    local left_2_Point_2 = left_2_Point + GetPerpendicularVector( CalculateDirection(left_2_Point, vLocation) ) * -150
    local left_2_vel = GetPerpendicularVector( CalculateDirection(left_2_Point, vLocation) ) * speed

    local right_1_Point = spawn_point + caster:GetRightVector() * 100
    local right_1_vel = GetPerpendicularVector( CalculateDirection(right_1_Point, vLocation) ) * -speed

    local right_2_Point = spawn_point + caster:GetRightVector() * 200
    local right_2_Point_2 = right_2_Point + GetPerpendicularVector( CalculateDirection(right_2_Point, vLocation) ) * 150
    local right_2_vel = GetPerpendicularVector( CalculateDirection(right_1_Point, vLocation) ) * -speed


    if self.count == 1 then
        self:FireLinearProjectile("particles/units/heroes/hero_kotl/kotl_illuminate_horsey.vpcf", vel, distance, radius, {origin=firstHorse, team = DOTA_UNIT_TARGET_TEAM_BOTH}, false, true, self:GetTalentSpecialValueFor("vision_radius"))
    
    elseif self.count == 2 then
        self:FireLinearProjectile("particles/units/heroes/hero_kotl/kotl_illuminate_horsey.vpcf", left_1_vel, distance, radius, {origin=left_1_Point, team = DOTA_UNIT_TARGET_TEAM_BOTH}, false, true, self:GetTalentSpecialValueFor("vision_radius"))
        self:FireLinearProjectile("particles/units/heroes/hero_kotl/kotl_illuminate_horsey.vpcf", right_1_vel, distance, radius, {origin=right_1_Point, team = DOTA_UNIT_TARGET_TEAM_BOTH}, false, true, self:GetTalentSpecialValueFor("vision_radius"))
    
    elseif self.count == 3 then
        self:FireLinearProjectile("particles/units/heroes/hero_kotl/kotl_illuminate_horsey.vpcf", vel, distance, radius, {origin=firstHorse, team = DOTA_UNIT_TARGET_TEAM_BOTH}, false, true, self:GetTalentSpecialValueFor("vision_radius"))
        self:FireLinearProjectile("particles/units/heroes/hero_kotl/kotl_illuminate_horsey.vpcf", left_1_vel, distance, radius, {origin=left_1_Point, team = DOTA_UNIT_TARGET_TEAM_BOTH}, false, true, self:GetTalentSpecialValueFor("vision_radius"))
        self:FireLinearProjectile("particles/units/heroes/hero_kotl/kotl_illuminate_horsey.vpcf", right_1_vel, distance, radius, {origin=right_1_Point, team = DOTA_UNIT_TARGET_TEAM_BOTH}, false, true, self:GetTalentSpecialValueFor("vision_radius"))
    
    elseif self.count == 4 then
        self:FireLinearProjectile("particles/units/heroes/hero_kotl/kotl_illuminate_horsey.vpcf", left_1_vel, distance, radius, {origin=left_1_Point, team = DOTA_UNIT_TARGET_TEAM_BOTH}, false, true, self:GetTalentSpecialValueFor("vision_radius"))
        self:FireLinearProjectile("particles/units/heroes/hero_kotl/kotl_illuminate_horsey.vpcf", right_1_vel, distance, radius, {origin=right_1_Point, team = DOTA_UNIT_TARGET_TEAM_BOTH}, false, true, self:GetTalentSpecialValueFor("vision_radius"))
        self:FireLinearProjectile("particles/units/heroes/hero_kotl/kotl_illuminate_horsey.vpcf", left_2_vel, distance, radius, {origin=left_2_Point_2, team = DOTA_UNIT_TARGET_TEAM_BOTH}, false, true, self:GetTalentSpecialValueFor("vision_radius"))
        self:FireLinearProjectile("particles/units/heroes/hero_kotl/kotl_illuminate_horsey.vpcf", right_2_vel, distance, radius, {origin=right_2_Point_2, team = DOTA_UNIT_TARGET_TEAM_BOTH}, false, true, self:GetTalentSpecialValueFor("vision_radius"))
    
    elseif self.count == 5 then
        self:FireLinearProjectile("particles/units/heroes/hero_kotl/kotl_illuminate_horsey.vpcf", vel, distance, radius, {origin=firstHorse, team = DOTA_UNIT_TARGET_TEAM_BOTH}, false, true, self:GetTalentSpecialValueFor("vision_radius"))
        self:FireLinearProjectile("particles/units/heroes/hero_kotl/kotl_illuminate_horsey.vpcf", left_1_vel, distance, radius, {origin=left_1_Point, team = DOTA_UNIT_TARGET_TEAM_BOTH}, false, true, self:GetTalentSpecialValueFor("vision_radius"))
        self:FireLinearProjectile("particles/units/heroes/hero_kotl/kotl_illuminate_horsey.vpcf", right_1_vel, distance, radius, {origin=right_1_Point, team = DOTA_UNIT_TARGET_TEAM_BOTH}, false, true, self:GetTalentSpecialValueFor("vision_radius"))
        self:FireLinearProjectile("particles/units/heroes/hero_kotl/kotl_illuminate_horsey.vpcf", left_2_vel, distance, radius, {origin=left_2_Point_2, team = DOTA_UNIT_TARGET_TEAM_BOTH}, false, true, self:GetTalentSpecialValueFor("vision_radius"))
        self:FireLinearProjectile("particles/units/heroes/hero_kotl/kotl_illuminate_horsey.vpcf", right_2_vel, distance, radius, {origin=right_2_Point_2, team = DOTA_UNIT_TARGET_TEAM_BOTH}, false, true, self:GetTalentSpecialValueFor("vision_radius"))
    
    end
end

modifier_kotl_illuminate = class({})

modifier_kotl_illuminate_spirit = class({})
function modifier_kotl_illuminate_spirit:CheckState()
    local state = { [MODIFIER_STATE_INVISIBLE] = true,
                    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                    [MODIFIER_STATE_UNSELECTABLE] = true,
                    [MODIFIER_STATE_UNTARGETABLE] = true,
                    [MODIFIER_STATE_ATTACK_IMMUNE] = true,
                    [MODIFIER_STATE_MAGIC_IMMUNE] = true,
                    [MODIFIER_STATE_COMMAND_RESTRICTED] = true,
                    [MODIFIER_STATE_NO_HEALTH_BAR] = true,
                    [MODIFIER_STATE_OUT_OF_GAME] = true
                    }
    return state
end

function modifier_kotl_illuminate_spirit:GetEffectName()
    return "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_spirit_form_ambient.vpcf"
end

function modifier_kotl_illuminate_spirit:GetStatusEffectName()
    return "particles/status_fx/status_effect_keeper_spirit_form.vpcf"
end

function modifier_kotl_illuminate_spirit:StatusEffectPriority()
    return 10
end

function modifier_kotl_illuminate_spirit:DeclareFunctions()
    return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL}
end

function modifier_kotl_illuminate_spirit:GetModifierInvisibilityLevel()
    return 0
end
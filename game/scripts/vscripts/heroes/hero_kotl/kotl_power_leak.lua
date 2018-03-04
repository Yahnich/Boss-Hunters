kotl_power_leak = class({})
LinkLuaModifier( "modifier_kotl_power_leak", "heroes/hero_kotl/kotl_power_leak.lua" ,LUA_MODIFIER_MOTION_NONE )

function kotl_power_leak:IsStealable()
    return true
end

function kotl_power_leak:IsHiddenWhenStolen()
    return false
end

if IsServer() then
    function kotl_power_leak:OnSpellStart()
        local caster = self:GetCaster()
        local target = self:GetCursorTarget()
        EmitSoundOn("Hero_KeeperOfTheLight.ManaLeak.Cast", caster)
        EmitSoundOn("Hero_KeeperOfTheLight.ManaLeak.Target", target)

        local leakCast = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_mana_leak_cast.vpcf", PATTACH_POINT_FOLLOW, target)
            ParticleManager:SetParticleControlEnt(leakCast, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true) 
            ParticleManager:SetParticleControlEnt(leakCast, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(leakCast)

        ParticleManager:FireParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_mana_leak.vpcf", PATTACH_ABSORIGIN, target, {})

        target:AddNewModifier(caster, self, "modifier_kotl_power_leak", {duration = self:GetTalentSpecialValueFor("duration")})

        if caster:HasTalent("special_bonus_unique_kotl_power_leak_2") then
            local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_kotl_power_leak_2"))
            for _,enemy in pairs(enemies) do
                if enemy ~= target then
                    local leakCast = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_mana_leak_cast.vpcf", PATTACH_POINT_FOLLOW, enemy)
                    ParticleManager:SetParticleControlEnt(leakCast, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true) 
                    ParticleManager:SetParticleControlEnt(leakCast, 1, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
                    ParticleManager:ReleaseParticleIndex(leakCast)

                    ParticleManager:FireParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_mana_leak.vpcf", PATTACH_ABSORIGIN, enemy, {})
                    enemy:AddNewModifier(caster, self, "modifier_kotl_power_leak", {duration = self:GetTalentSpecialValueFor("duration")})
                end
            end
        end
    end
end

modifier_kotl_power_leak = class({})

function modifier_kotl_power_leak:OnCreated()
    self.damagereduction = self:GetAbility():GetTalentSpecialValueFor("damage_reduction")
    self:IncrementStackCount()
end

function modifier_kotl_power_leak:OnRefresh()
    self.damagereduction = self:GetAbility():GetTalentSpecialValueFor("damage_reduction")
    self:IncrementStackCount()
end

function modifier_kotl_power_leak:OnRemoved()
    if IsServer() then
        EmitSoundOn("Hero_KeeperOfTheLight.ManaLeak.Stun", self:GetParent())
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_stunned", {duration = self:GetAbility():GetTalentSpecialValueFor("stun_duration")})
    end
end

function modifier_kotl_power_leak:DeclareFunctions()
    funcs = {
                MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
                MODIFIER_EVENT_ON_ABILITY_START,
            }
    return funcs
end

function modifier_kotl_power_leak:GetModifierTotalDamageOutgoing_Percentage()
    return self.damagereduction * self:GetStackCount()
end

function modifier_kotl_power_leak:OnAbilityStart(params)
    if params.unit == self:GetParent() then
        self:IncrementStackCount()
        if IsServer() then
            local leakDrop = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_mana_leak.vpcf", PATTACH_ABSORIGIN, params.unit)
            ParticleManager:SetParticleControl(leakDrop, 0, params.unit:GetAbsOrigin()) 
            ParticleManager:ReleaseParticleIndex(leakDrop)
        end
        if self:GetStackCount() * self.damagereduction >= 100 then
            self:Destroy()
        end
    end
end

function modifier_kotl_power_leak:GetEffectName()
    return "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_mana_leak.vpcf"
end
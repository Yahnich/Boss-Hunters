pa_kunai_toss = class({})
LinkLuaModifier( "modifier_kunai_toss_slow", "heroes/hero_pa/pa_kunai_toss.lua" ,LUA_MODIFIER_MOTION_NONE )

function pa_kunai_toss:IsStealable()
    return true
end

function pa_kunai_toss:IsHiddenWhenStolen()
    return false
end

function pa_kunai_toss:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    local maxTargets = self:GetSpecialValueFor("max_targets")-1
    local currentTargets = 0

    self.TotesBounces = self:GetSpecialValueFor("bounces")*self:GetSpecialValueFor("max_targets")
    self.CurrentBounces = 0

    self:tossKunai(target)

    EmitSoundOn("Hero_PhantomAssassin.Dagger.Cast", caster)

    local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), self:GetSpecialValueFor("radius"), {})
    for _,enemy in pairs(enemies) do
        if enemy ~= target and currentTargets < maxTargets then
            self:tossKunai(enemy)
            currentTargets = currentTargets + 1
        end
    end
end

function pa_kunai_toss:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()
    if hTarget ~= nil and hTarget:IsAlive() then
        EmitSoundOn("Hero_PhantomAssassin.Dagger.Target", caster)

        caster:PerformGenericAttack(hTarget, true, 0, false, true)
        self:DealDamage(caster, hTarget, self:GetSpecialValueFor("damage"), {}, 0)
        hTarget:AddNewModifier(caster, self, "modifier_kunai_toss_slow", {Duration = self:GetSpecialValueFor("slow_duration")})
        
        if caster:HasTalent("special_bonus_unique_pa_kunai_toss_1") then
            local enemies = caster:FindEnemyUnitsInRadius(vLocation, self:GetSpecialValueFor("radius"), {})
            for _,enemy in pairs(enemies) do
                if enemy ~= hTarget and self.CurrentBounces < self.TotesBounces then
                    self:FireTrackingProjectile("particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf", hTarget, 1200, {}, 0, true, true, 100)
                    self.CurrentBounces = self.CurrentBounces + 1
                    break
                end
            end
        end
    end
end

function pa_kunai_toss:tossKunai(target)
    self:FireTrackingProjectile("particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf", target, 1200, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_2, true, true, 100)
end

modifier_kunai_toss_slow = class({})
function modifier_kunai_toss_slow:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }   
    return funcs
end

function modifier_kunai_toss_slow:GetModifierMoveSpeedBonus_Percentage()
    return self:GetTalentSpecialValueFor("slow")
end

function modifier_kunai_toss_slow:IsDebuff()
    return true
end

function modifier_kunai_toss_slow:GetEffectName()
    return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger_debuff.vpcf"
end
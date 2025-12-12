invoker_tornado_bh = class({})

function invoker_tornado_bh:IsStealable()
    return true
end

function invoker_tornado_bh:IsHiddenWhenStolen()
    return false
end

function invoker_tornado_bh:OnAbilityPhaseStart()
    self:GetCaster():StartGesture(ACT_DOTA_CAST_TORNADO)
    return true
end

function invoker_tornado_bh:OnAbilityPhaseInterrupted()
    self:GetCaster():RemoveGesture(ACT_DOTA_CAST_TORNADO)
end

function invoker_tornado_bh:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    local speed = 1000

    local velocity = CalculateDirection(point, caster:GetAbsOrigin()) * speed

    local travel_distance = self:GetSpecialValueFor("travel_distance")

    local radius = self:GetSpecialValueFor("radius")

    self:FireLinearProjectile("particles/units/heroes/hero_invoker/invoker_tornado.vpcf", velocity, travel_distance, radius, {}, false, true, 200)
end

function invoker_tornado_bh:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()

    if hTarget then
        local lift_duration = self:GetSpecialValueFor("lift_duration")

        local base_damage = self:GetSpecialValueFor("base_damage")
        local wex_damage = self:GetSpecialValueFor("wex_damage")
        local damage = base_damage + wex_damage

        local height = 350

        hTarget:ApplyKnockBack(vLocation, lift_duration, lift_duration, 0, height, caster, self, true)
        self:DealDamage(caster, hTarget, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
    else
        AddFOWViewer(caster:GetTeam(), vLocation, 200, self:GetSpecialValueFor("end_vision_duration"), true)
    end
end
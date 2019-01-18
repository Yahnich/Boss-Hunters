invoker_emp_bh = class({})

function invoker_emp_bh:IsStealable()
    return true
end

function invoker_emp_bh:IsHiddenWhenStolen()
    return false
end

function invoker_emp_bh:OnAbilityPhaseStart()
    self:GetCaster():StartGesture(ACT_DOTA_CAST_EMP)
    return true
end

function invoker_emp_bh:OnAbilityPhaseInterrupted()
    self:GetCaster():RemoveGesture(ACT_DOTA_CAST_EMP)
end

function invoker_emp_bh:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    
    local wex_level = caster:FindAbilityByName("invoker_w"):GetLevel()

    local delay = self:GetSpecialValueFor("delay")
    local radius = self:GetSpecialValueFor("radius")

    local base_damage = self:GetSpecialValueFor("base_damage")
    local damage_per_wex = self:GetSpecialValueFor("damage_per_wex")
    local damage = base_damage + (damage_per_wex * wex_level)

    local mana_drain = self:GetSpecialValueFor("delay")/100

    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_invoker/invoker_emp.vpcf", PATTACH_POINT, caster)
                ParticleManager:SetParticleControl(nfx, 0, point)
                ParticleManager:SetParticleControl(nfx, 1, Vector(radius, radius, radius))

    Timers:CreateTimer(delay, function()
        ParticleManager:ClearParticle(nfx)

        local enemies = caster:FindEnemyUnitsInRadius(point, radius)
        for _,enemy in pairs(enemies) do
            local damage = self:DealDamage(caster, enemy, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
            caster:GiveMana(damage * mana_drain)
        end
    end)
end

kotl_blind = class({})

function kotl_blind:IsStealable()
    return true
end

function kotl_blind:IsHiddenWhenStolen()
    return false
end

function kotl_blind:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    EmitSoundOnLocationWithCaster(point, "Hero_KeeperOfTheLight.BlindingLight", caster)

    ParticleManager:FireParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_aoe.vpcf", PATTACH_POINT, caster, {[0]="attach_attack1", [1]=point, [2]="attach_attack1"})

    local enemies = caster:FindEnemyUnitsInRadius(point, self:GetSpecialValueFor("radius"))
    for _,enemy in pairs(enemies) do
        enemy:Blind(self:GetSpecialValueFor("miss_rate"), self, caster, self:GetSpecialValueFor("miss_duration"))
        enemy:ApplyKnockBack(point, 0.4, 0.4, 250, 50, caster, self)
    end
end
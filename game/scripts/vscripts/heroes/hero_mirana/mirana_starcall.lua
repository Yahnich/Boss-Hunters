mirana_starcall = class({})
LinkLuaModifier("modifier_mirana_starcall", "heroes/hero_mirana/mirana_starcall", LUA_MODIFIER_MOTION_NONE)

function mirana_starcall:IsStealable()
    return true
end

function mirana_starcall:IsHiddenWhenStolen()
    return false
end

function mirana_starcall:GetIntrinsicModifierName()
    return "modifier_mirana_starcall"
end

function mirana_starcall:OnSpellStart()
    local caster = self:GetCaster()
    local damage = self:GetSpecialValueFor("damage")
    local agi_damage = self:GetSpecialValueFor("agi_damage")/100

    EmitSoundOn("Ability.Starfall", caster)

    damage = damage + caster:GetAgility() * agi_damage

    local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetSpecialValueFor("radius"))
    for _,enemy in pairs(enemies) do
        ParticleManager:FireParticle("particles/econ/items/mirana/mirana_starstorm_bow/mirana_starstorm_starfall_attack.vpcf", PATTACH_POINT_FOLLOW, enemy, {[0]=enemy:GetAbsOrigin()})
        Timers:CreateTimer(0.57, function() --particle delay
            EmitSoundOn("Ability.StarfallImpact", enemy)
            self:DealDamage(caster, enemy, damage, {}, 0)
        end)
    end

    Timers:CreateTimer(0.8, function()
        local enemies2 = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self:GetSpecialValueFor("radius"))
        for _,enemy2 in pairs(enemies2) do
            ParticleManager:FireParticle("particles/units/heroes/hero_mirana/mirana_loadout.vpcf", PATTACH_POINT_FOLLOW, enemy2, {[0]=enemy2:GetAbsOrigin()})
            Timers:CreateTimer(0.57, function() --particle delay
                EmitSoundOn("Ability.StarfallImpact", enemy2)
                self:DealDamage(caster, enemy2, damage*75/100, {}, 0)
            end)
        end
    end)
end

modifier_mirana_starcall = class({})
function modifier_mirana_starcall:OnCreated(table)
    if IsServer() then
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_mirana_starcall:OnIntervalThink()
    if self:GetParent():HasTalent("special_bonus_unique_mirana_starcall_1") and self:GetParent():IsAlive() then
        local damage = self:GetSpecialValueFor("damage")
        local agi_damage = self:GetSpecialValueFor("agi_damage")/100
        damage = damage + self:GetParent():GetAgility() * agi_damage

        local enemies = self:GetParent():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetSpecialValueFor("radius"))
        for _,enemy in pairs(enemies) do
            ParticleManager:FireParticle("particles/econ/items/mirana/mirana_starstorm_bow/mirana_starstorm_starfall_attack.vpcf", PATTACH_POINT_FOLLOW, enemy, {[0]=enemy:GetAbsOrigin()})
            Timers:CreateTimer(0.57, function() --particle delay
                EmitSoundOn("Ability.StarfallImpact", enemy)
                self:GetAbility():DealDamage(self:GetParent(), enemy, damage, {}, 0)
            end)
        end
        self:StartIntervalThink(self:GetParent():FindTalentValue("special_bonus_unique_mirana_starcall_1"))
    end
end

function modifier_mirana_starcall:IsHidden()
    return true
end
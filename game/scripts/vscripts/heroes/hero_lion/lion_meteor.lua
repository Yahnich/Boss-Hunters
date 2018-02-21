lion_meteor = class({})
LinkLuaModifier( "modifier_lion_meteor", "heroes/hero_lion/lion_meteor.lua",LUA_MODIFIER_MOTION_NONE )

function lion_meteor:IsStealable()
    return true
end

function lion_meteor:IsHiddenWhenStolen()
    return false
end

function lion_meteor:GetAOERadius()
    return self:GetTalentSpecialValueFor("radius")
end

function lion_meteor:OnSpellStart()
    local caster = self:GetCaster()

    local radius = self:GetSpecialValueFor("radius")

    local point = self:GetCursorPosition()
	
    if self:GetCursorTarget() then
        point = self:GetCursorTarget():GetAbsOrigin()
    end

    EmitSoundOn("Hero_Invoker.ChaosMeteor.Cast", caster)

    ParticleManager:FireParticle("particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf", PATTACH_POINT, caster, {[0]=point+Vector(0,0,1000),[1]=point,[2]=Vector(1.3,0,0)}) --1.3 is the particle land time
    
    local newRadi = caster:FindTalentValue("special_bonus_unique_lion_meteor_2")
    local randoVect = Vector(RandomInt(-newRadi,newRadi), RandomInt(-newRadi,newRadi), 0)
    pointRando = point + randoVect

    if caster:HasTalent("special_bonus_unique_lion_meteor_2") then
        ParticleManager:FireParticle("particles/units/heroes/hero_invoker/invoker_chaos_meteor_fly.vpcf", PATTACH_POINT, caster, {[0]=pointRando+Vector(0,0,1000),[1]=pointRando,[2]=Vector(1.3,0,0)}) --1.3 is the particle land time
    end

    Timers:CreateTimer(1.3, function()
        EmitSoundOnLocationWithCaster(point, "Hero_Invoker.ChaosMeteor.Impact", caster)

        if caster:HasTalent("special_bonus_unique_lion_meteor_2") then
            EmitSoundOnLocationWithCaster(pointRando, "Hero_Invoker.ChaosMeteor.Impact", caster)

            ParticleManager:FireParticle("particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf", PATTACH_POINT, caster, {[0]=pointRando, [1]=Vector(radius,radius,radius)}) --1.3 is the particle land time
            local enemies = caster:FindEnemyUnitsInRadius(pointRando, radius, {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})
            for _,enemy in pairs(enemies) do
                enemy:AddNewModifier(caster, self, "modifier_lion_meteor", {Duration = self:GetSpecialValueFor("burn_duration")})
                self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
            end
        end

        ParticleManager:FireParticle("particles/units/heroes/hero_invoker/invoker_sun_strike.vpcf", PATTACH_POINT, caster, {[0]=point, [1]=Vector(radius,radius,radius)}) --1.3 is the particle land time
        local enemies = caster:FindEnemyUnitsInRadius(point, radius, {flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES})
        for _,enemy in pairs(enemies) do
            enemy:AddNewModifier(caster, self, "modifier_lion_meteor", {Duration = self:GetSpecialValueFor("burn_duration")})
            self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)

            if caster:HasTalent("special_bonus_unique_lion_meteor_1") then
                self:Stun(enemy, caster:FindTalentValue("special_bonus_unique_lion_meteor_1"), false)
            end
        end

        local distance = self:GetTalentSpecialValueFor("damage")
        local direction = CalculateDirection(caster:GetAbsOrigin(), point)

        self:FireLinearProjectile("particles/units/heroes/hero_invoker/invoker_chaos_meteor.vpcf", direction*self:GetSpecialValueFor("speed"), distance, self:GetSpecialValueFor("radius"), {origin = point}, false, true, self:GetSpecialValueFor("vision_distance"))
    end)
end

function lion_meteor:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()

    if hTarget ~= nil then
        hTarget:AddNewModifier(caster, self, "modifier_lion_meteor", {Duration = self:GetSpecialValueFor("burn_duration")})
        self:DealDamage(caster, hTarget, self:GetTalentSpecialValueFor("damage"), {}, 0)
    else
        EmitSoundOnLocationWithCaster(vLocation, "Hero_Invoker.ChaosMeteor.Impact", caster)
    end
end

modifier_lion_meteor = class({})
function modifier_lion_meteor:OnCreated(table)
    if IsServer() then
        self:StartIntervalThink(self:GetSpecialValueFor("tick_rate"))
    end
end

function modifier_lion_meteor:OnIntervalThink()
    self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self:GetTalentSpecialValueFor("burn_damage"), {}, 0)
end

function modifier_lion_meteor:GetEffectName()
    return "particles/units/heroes/hero_invoker/invoker_chaos_meteor_burn_debuff.vpcf"
end
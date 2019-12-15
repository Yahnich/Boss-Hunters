tusk_snow = class({})

function tusk_snow:IsStealable()
    return true
end

function tusk_snow:IsHiddenWhenStolen()
    return false
end

function tusk_snow:GetAOERadius()
    return self:GetTalentSpecialValueFor("radius")
end

function tusk_snow:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    EmitSoundOn("Hero_Tusk.Snowball.Cast", caster)
	if target:TriggerSpellAbsorb( self ) then return end
    self:FireTrackingProjectile("particles/units/heroes/hero_tusk/tusk_snow_copy.vpcf", target, 1000, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_2, false, true, 100)
    if caster:HasTalent("special_bonus_unique_tusk_snow_2") then
        self:Stun(target, caster:FindTalentValue("special_bonus_unique_tusk_snow_2"), false)
    end

    if caster:HasTalent("special_bonus_unique_tusk_snow_1") then
        local maxCount = caster:FindTalentValue("special_bonus_unique_tusk_snow_1")
        local curCount = 0
        local delay = 0.25
        Timers:CreateTimer(delay, function()
            if curCount < maxCount then
                local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"))
                for _,enemy in pairs(enemies) do
                    self:FireTrackingProjectile("particles/units/heroes/hero_tusk/tusk_snow_copy.vpcf", enemy, 1000, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_2, false, true, 100)
                        curCount = curCount + 1
                    break
                end
                return delay
            else
                return nil
            end
        end)
    end
end

function tusk_snow:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()
    
    if hTarget ~= nil then
        EmitSoundOn("Hero_Tusk.Snowball.ProjectileHit", hTarget)
        local radius = self:GetTalentSpecialValueFor("radius")
        ParticleManager:FireParticle("particles/units/heroes/hero_lich/lich_frost_nova.vpcf", PATTACH_ABSORIGIN, caster, {[0]=vLocation, [1]=Vector(radius,radius,radius)})
        local enemies = caster:FindEnemyUnitsInRadius(hTarget:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"))
        for _,enemy in pairs(enemies) do
            for i=1,self:GetTalentSpecialValueFor("chill_amount") do
                enemy:AddChill(self, caster, self:GetTalentSpecialValueFor("chill_duration"))
            end
            self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
        end
    end
end

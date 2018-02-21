lion_earth_spike = class({})

function lion_earth_spike:IsStealable()
    return true
end

function lion_earth_spike:IsHiddenWhenStolen()
    return false
end

function lion_earth_spike:GetAOERadius()
    return self:GetTalentSpecialValueFor("radius")
end

function lion_earth_spike:OnAbilityPhaseStart()
    local caster = self:GetCaster()

    ParticleManager:FireParticle("particles/units/heroes/hero_lion/lion_spell_impale_staff.vpcf", PATTACH_POINT_FOLLOW, caster, {[0]="attach_attack1"})
    return true
end

function lion_earth_spike:OnSpellStart()
    local caster = self:GetCaster()

    local point = self:GetCursorPosition()
	
    if self:GetCursorTarget() then
        point = self:GetCursorTarget():GetAbsOrigin()
    end

    EmitSoundOn("Hero_Lion.Impale", caster)

    local distance = CalculateDistance(point, caster:GetAbsOrigin())
    local direction = CalculateDirection(point,caster:GetAbsOrigin())
    local velocity = direction * self:GetTalentSpecialValueFor("speed")

    self:FireLinearProjectile("particles/units/heroes/hero_lion/lion_spell_impale.vpcf", velocity, distance, self:GetTalentSpecialValueFor("width"), {}, false, true, 250)
end

function lion_earth_spike:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()
	
    if hTarget ~= nil then
        EmitSoundOn("Hero_Lion.ImpaleHitTarget", hTarget)

        ParticleManager:FireParticle("particles/units/heroes/hero_lion/lion_spell_impale_hit_spikes.vpcf", PATTACH_POINT, hTarget, {[0]=hTarget:GetAbsOrigin(),[1]=hTarget:GetAbsOrigin(),[2]=hTarget:GetAbsOrigin()})

        hTarget:ApplyKnockBack(vLocation, 0.5, 0.5, 0, 350, caster, self)
        self:Stun(hTarget, self:GetTalentSpecialValueFor("duration"), false)
        self:DealDamage(caster, hTarget, self:GetTalentSpecialValueFor("damage"), {}, 0)
    else
        EmitSoundOnLocationWithCaster(vLocation, "Hero_Leshrac.Split_Earth", caster)

        local radius = self:GetTalentSpecialValueFor("radius")
        ParticleManager:FireParticle("particles/units/heroes/hero_leshrac/leshrac_split_earth.vpcf", PATTACH_POINT, caster, {[0]=vLocation,[1]=Vector(radius,radius,radius),[2]=vLocation})
        
        local enemies = caster:FindEnemyUnitsInRadius(vLocation, radius, {})
        for _,enemy in pairs(enemies) do
            enemy:ApplyKnockBack(vLocation, 0.5, 0.5, 0, 350, caster, self)
            self:Stun(enemy, self:GetTalentSpecialValueFor("duration"), false)
            self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
        end
    end
end
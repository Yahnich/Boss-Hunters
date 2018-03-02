mag_polarity_2 = class({})
function mag_polarity_2:IsStealable()
    return true
end

function mag_polarity_2:IsHiddenWhenStolen()
    return false
end

function mag_polarity_2:OnInventoryContentsChanged()
    if self:GetCaster():HasScepter() then
        self:SetLevel(1)
        self:SetHidden(false)
        self:SetActivated(true)
    else
        self:SetLevel(0)
        self:SetHidden(true)
        self:SetActivated(false)
    end
end

function mag_polarity_2:GetBehavior()
    if self:GetCaster():HasScepter() then
        return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE
    end

    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_HIDDEN + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE
end

function mag_polarity_2:GetAOERadius()
    return self:GetTalentSpecialValueFor("radius")
end

function mag_polarity_2:OnAbilityPhaseStart()
    EmitSoundOn("Hero_Magnataur.ReversePolarity.Anim", self:GetCaster())
    return true
end

function mag_polarity_2:OnSpellStart()
    local caster = self:GetCaster()
    local radius = self:GetTalentSpecialValueFor("radius")
    local point = self:GetCursorPosition()

    EmitSoundOn("Hero_Magnataur.ReversePolarity.Cast", self:GetCaster())

    ParticleManager:FireParticle("particles/units/heroes/hero_magnus/magnus_polarity_2.vpcf", PATTACH_POINT, caster, {[0]=Vector(1,0,0), [1]=Vector(radius,radius,radius), [2]=Vector(0.3,0,0), [3]=point})
    local magnets = caster:FindFriendlyUnitsInRadius(point, radius)
    for _,magnet in pairs(magnets) do
        if magnet:HasModifier("modifier_mag_magnet") then
            ParticleManager:FireParticle("particles/units/heroes/hero_magnus/magnus_polarity_2.vpcf", PATTACH_POINT, caster, {[0]=Vector(1,0,0), [1]=Vector(radius,radius,radius), [2]=Vector(0.3,0,0), [3]=magnet:GetAbsOrigin()})
            local enemies = caster:FindEnemyUnitsInRadius(magnet:GetAbsOrigin(), radius, {})
            for _,enemy in pairs(enemies) do
                ParticleManager:FireRopeParticle("particles/units/heroes/hero_magnataur/magnataur_reverse_polarity_pull.vpcf", PATTACH_POINT, caster, enemy, {[0]=magnet:GetAbsOrigin(), [1]=enemy:GetAbsOrigin()})

                EmitSoundOn("Hero_Magnataur.ReversePolarity.Cast", enemy)
				enemy:ApplyKnockBack(point, 0.1, 0.1, radius, 0, caster, self)
				self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
            end
        end
    end
	
	local enemies = caster:FindEnemyUnitsInRadius(point, radius, {})
    for _,enemy in pairs(enemies) do
        ParticleManager:FireRopeParticle("particles/units/heroes/hero_magnataur/magnataur_reverse_polarity_pull.vpcf", PATTACH_POINT, caster, enemy, {[0]=point, [1]=enemy:GetAbsOrigin()})
        EmitSoundOn("Hero_Magnataur.ReversePolarity.Cast", enemy)
        enemy:ApplyKnockBack(point, 0.1, 0.1, radius, 0, caster, self)
        self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
    end
end
broodmother_bite = class({})
LinkLuaModifier("modifier_broodmother_bite", "heroes/hero_broodmother/broodmother_bite", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_broodmother_bite_poison", "heroes/hero_broodmother/broodmother_bite", LUA_MODIFIER_MOTION_NONE)

function broodmother_bite:GetIntrinsicModifierName()
    return "modifier_broodmother_bite"
end

modifier_broodmother_bite = class({})
function modifier_broodmother_bite:IsHidden() return true end
function modifier_broodmother_bite:IsDebuff() return false end

function modifier_broodmother_bite:DeclareFunctions()
    return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_broodmother_bite:OnAttackLanded(params)
    if IsServer() then
        if params.attacker == self:GetParent() then
            params.target:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_broodmother_bite_poison", {Duration = self:GetTalentSpecialValueFor("duration")})
        end
    end
end

modifier_broodmother_bite_poison = class({})
function modifier_broodmother_bite_poison:IsDebuff() return true end

function modifier_broodmother_bite_poison:OnCreated(table)
    if IsServer() then
        self:StartIntervalThink(1)
    end
end

function modifier_broodmother_bite_poison:OnIntervalThink()
    if self:GetCaster():IsHero() then
        self.damage = self:GetCaster():GetAgility() * (self:GetTalentSpecialValueFor("damage")/100)
    elseif self:GetCaster():GetOwnerEntity() then
        self.damage = self:GetCaster():GetOwnerEntity():GetAgility() * (self:GetTalentSpecialValueFor("damage")/100)
    end
    self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), self.damage, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
end

function modifier_broodmother_bite_poison:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
            MODIFIER_PROPERTY_MISS_PERCENTAGE}
end

function modifier_broodmother_bite_poison:GetModifierMoveSpeedBonus_Percentage()
    return self:GetTalentSpecialValueFor("bonus_movespeed")
end

function modifier_broodmother_bite_poison:GetModifierMiss_Percentage()
    return self:GetTalentSpecialValueFor("miss_chance")
end

function modifier_broodmother_bite_poison:GetEffectName()
    return "particles/units/heroes/hero_broodmother/broodmother_incapacitatingbite_debuff.vpcf"
end
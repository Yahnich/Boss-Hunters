phenx_heart = class({})
LinkLuaModifier( "modifier_phenx_heart_caster", "heroes/hero_phenx/phenx_heart.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_phenx_heart_burn", "heroes/hero_phenx/phenx_heart.lua", LUA_MODIFIER_MOTION_NONE )

function phenx_heart:GetIntrinsicModifierName()
    return "modifier_phenx_heart_caster"
end


modifier_phenx_heart_caster = class({})
function modifier_phenx_heart_caster:OnCreated(table)
    if IsServer() then
        self.nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_flameguard.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
        ParticleManager:SetParticleControlEnt(self.nfx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
        ParticleManager:SetParticleControlEnt(self.nfx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
        ParticleManager:SetParticleControl(self.nfx, 2, Vector(self:GetTalentSpecialValueFor("radius"),self:GetTalentSpecialValueFor("radius"),self:GetTalentSpecialValueFor("radius")))
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_phenx_heart_caster:OnIntervalThink()
    GridNav:DestroyTreesAroundPoint(self:GetParent():GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"), false)
end

function modifier_phenx_heart_caster:OnRemoved()
    ParticleManager:DestroyParticle(self.nfx, false)
end

function modifier_phenx_heart_caster:IsAura()
    return true
end

function modifier_phenx_heart_caster:GetAuraDuration()
    return 1.0
end

function modifier_phenx_heart_caster:GetAuraRadius()
    return self:GetTalentSpecialValueFor("radius")
end

function modifier_phenx_heart_caster:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_phenx_heart_caster:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_phenx_heart_caster:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_phenx_heart_caster:GetModifierAura()
    return "modifier_phenx_heart_burn"
end

function modifier_phenx_heart_caster:IsAuraActiveOnDeath()
    return true
end

function modifier_phenx_heart_caster:IsHidden()
    return true
end

modifier_phenx_heart_burn = class({})
function modifier_phenx_heart_burn:OnCreated(table)
    if IsServer() then
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_phenx_heart_burn:OnIntervalThink()
    local damage = self:GetCaster():GetHealth()*self:GetTalentSpecialValueFor("hp_percent")/100
    self:GetAbility():DealDamage(self:GetCaster(), self:GetParent(), damage, {}, 0)
    self:StartIntervalThink(1.0)
end

function modifier_phenx_heart_burn:GetEffectName()
    return "particles/units/heroes/hero_phoenix/phoenix_supernova_radiance.vpcf"
end
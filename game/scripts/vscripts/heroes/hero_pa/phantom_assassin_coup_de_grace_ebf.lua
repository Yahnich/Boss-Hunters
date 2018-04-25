phantom_assassin_coup_de_grace_ebf = class({})
LinkLuaModifier( "modifier_phantom_assassin_coup_de_grace_ebf", "heroes/hero_pa/phantom_assassin_coup_de_grace_ebf", LUA_MODIFIER_MOTION_NONE )

function phantom_assassin_coup_de_grace_ebf:GetIntrinsicModifierName()
    return "modifier_phantom_assassin_coup_de_grace_ebf"
end

modifier_phantom_assassin_coup_de_grace_ebf = class({})
function modifier_phantom_assassin_coup_de_grace_ebf:DeclareFunctions()
    return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
            MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_phantom_assassin_coup_de_grace_ebf:GetModifierPreAttack_CriticalStrike( params )
    if RollPercentage(self:GetTalentSpecialValueFor("crit_chance")) and not params.attacker:PassivesDisabled() then
        local parent = self:GetParent()
        self.on_crit = true
        EmitSoundOn( "Hero_ChaosKnight.ChaosStrike", parent)
        return self:GetTalentSpecialValueFor("crit_bonus")
    end
end

function modifier_phantom_assassin_coup_de_grace_ebf:OnAttackLanded( params )
    if self.on_crit and params.attacker == self:GetParent() then
        -- If that attack was marked as a critical strike, apply the particles
            local coup_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, params.attacker)
            ParticleManager:SetParticleControlEnt(coup_pfx, 0, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetAbsOrigin(), true)
            ParticleManager:SetParticleControlEnt(coup_pfx, 1, params.target, PATTACH_ABSORIGIN_FOLLOW, "attach_origin", params.target:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(coup_pfx)
            self.on_crit = false
    end
end

function modifier_phantom_assassin_coup_de_grace_ebf:IsPassive()
    return true
end

function modifier_phantom_assassin_coup_de_grace_ebf:IsHidden()
    return true
end
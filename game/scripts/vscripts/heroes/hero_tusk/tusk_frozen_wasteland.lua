tusk_frozen_wasteland = class({})
LinkLuaModifier( "modifier_tusk_frozen_wasteland", "heroes/hero_tusk/tusk_frozen_wasteland.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_tusk_frozen_wasteland_effect", "heroes/hero_tusk/tusk_frozen_wasteland.lua" ,LUA_MODIFIER_MOTION_NONE )

function tusk_frozen_wasteland:IsStealable()
    return true
end

function tusk_frozen_wasteland:IsHiddenWhenStolen()
    return false
end

function tusk_frozen_wasteland:GetAOERadius()
    return self:GetTalentSpecialValueFor("radius")
end

function tusk_frozen_wasteland:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    EmitSoundOn("Hero_Tusk.FrozenSigil.Cast", caster)

    if target then
        target:AddNewModifier(caster, self, "modifier_tusk_frozen_wasteland", {Duration = self:GetTalentSpecialValueFor("duration")}) 
    else
        caster:AddNewModifier(caster, self, "modifier_tusk_frozen_wasteland", {Duration = self:GetTalentSpecialValueFor("duration")})
    end    
end

modifier_tusk_frozen_wasteland = class({})
function modifier_tusk_frozen_wasteland:OnCreated(table)
    if IsServer() then
        EmitSoundOn("Hero_Tusk.FrozenSigil", self:GetParent())

        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tusk/tusk_frozen_sigil.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
                    ParticleManager:SetParticleControlEnt(self.nfx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
                    ParticleManager:SetParticleControl(self.nfx, 1, Vector(self:GetTalentSpecialValueFor("radius"), 0, -self:GetTalentSpecialValueFor("radius")))
        self:AttachEffect(nfx)
        self:StartIntervalThink(0.1)
    end
end

function modifier_tusk_frozen_wasteland:OnIntervalThink()
    if self:GetCaster():HasTalent("special_bonus_unique_tusk_frozen_wasteland_2") then
        local damage = self:GetParent():GetStrength() * self:GetCaster():FindTalentValue("special_bonus_unique_tusk_frozen_wasteland_2")/100
        local enemies = self:GetParent():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"))
        for _,enemy in pairs(enemies) do
            self:GetAbility():DealDamage(self:GetCaster(), enemy, damage, {damage_type=DAMAGE_TYPE_MAGICAL, damage_flags=DOTA_DAMAGE_FLAG_NONE}, 0)
        end
        self:StartIntervalThink(1.0)
    end
end

function modifier_tusk_frozen_wasteland:OnRemoved()
    if IsServer() then
        StopSoundOn("Hero_Tusk.FrozenSigil", self:GetParent())
    end
end

function modifier_tusk_frozen_wasteland:IsAura()
    return true
end

function modifier_tusk_frozen_wasteland:GetAuraDuration()
    return 0.5
end

function modifier_tusk_frozen_wasteland:GetAuraRadius()
    return self:GetTalentSpecialValueFor("radius")
end

function modifier_tusk_frozen_wasteland:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_tusk_frozen_wasteland:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_tusk_frozen_wasteland:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_tusk_frozen_wasteland:GetModifierAura()
    return "modifier_tusk_frozen_wasteland_effect"
end

function modifier_tusk_frozen_wasteland:IsAuraActiveOnDeath()
    return false
end

function modifier_tusk_frozen_wasteland:IsHidden()
    return false
end

modifier_tusk_frozen_wasteland_effect = class({})
function modifier_tusk_frozen_wasteland_effect:DeclareFunctions()
    local funcs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
                    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT}
    return funcs
end

function modifier_tusk_frozen_wasteland_effect:GetModifierMoveSpeedBonus_Percentage()
    return self:GetTalentSpecialValueFor("slow_move")
end

function modifier_tusk_frozen_wasteland_effect:GetModifierAttackSpeedBonus_Constant()
    return self:GetTalentSpecialValueFor("slow_attack")
end

function modifier_tusk_frozen_wasteland_effect:GetEffectName()
    return "particles/units/heroes/hero_tusk/tusk_frozen_sigil_status.vpcf"
end
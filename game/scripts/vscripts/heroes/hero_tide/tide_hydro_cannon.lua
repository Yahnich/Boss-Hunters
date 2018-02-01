tide_hydro_cannon = class({})
LinkLuaModifier( "modifier_hydro_cannon", "heroes/hero_tide/tide_hydro_cannon.lua" ,LUA_MODIFIER_MOTION_NONE )

function tide_hydro_cannon:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    if self:GetCursorTarget() then
        point = self:GetCursorTarget():GetAbsOrigin()
    end

    EmitSoundOn("Ability.GushCast", caster)

    local info = 
    {
        Ability = self,
        EffectName = "particles/units/heroes/hero_tidehunter/tidehunter_gush_upgrade.vpcf",
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = self:GetTrueCastRange(),
        fStartRadius = 240,
        fEndRadius = 240,
        Source = caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_ALL,
        fExpireTime = GameRules:GetGameTime() + 10.0,
        bDeleteOnHit = true,
        vVelocity = caster:GetForwardVector() * 1500,
        bProvidesVision = true,
        iVisionRadius = self:GetTalentSpecialValueFor("width"),
        iVisionTeamNumber = caster:GetTeamNumber()
    }
    projectile = ProjectileManager:CreateLinearProjectile(info)
end

function tide_hydro_cannon:OnProjectileHit(hTarget, vLocation)
    local caster = self:GetCaster()

    StopSoundOn("Ability.GushCast", caster)

    if hTarget ~= nil then
        EmitSoundOn("Ability.GushImpact", hTarget)

        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tidehunter/tidehunter_gush_splash.vpcf", PATTACH_POINT, caster)
        ParticleManager:SetParticleControl(nfx, 3, hTarget:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(nfx)

        self:DealDamage(caster, hTarget, self:GetTalentSpecialValueFor("damage"), {}, 0)
        hTarget:AddNewModifier(caster, self, "modifier_hydro_cannon", {Duration = self:GetTalentSpecialValueFor("duration")})
    end
end

modifier_hydro_cannon = class({})
function modifier_hydro_cannon:DeclareFunctions()
    funcs = {
                MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
                MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
            }
    return funcs
end

function modifier_hydro_cannon:GetModifierPhysicalArmorBonus()
    return self:GetTalentSpecialValueFor("reduc_armor")
end

function modifier_hydro_cannon:GetModifierMoveSpeedBonus_Percentage()
    return self:GetTalentSpecialValueFor("move_speed")
end

function modifier_hydro_cannon:GetEffectName()
    return "particles/units/heroes/hero_tidehunter/tidehunter_gush_slow.vpcf"
end

function modifier_hydro_cannon:IsDebuff()
    return true
end
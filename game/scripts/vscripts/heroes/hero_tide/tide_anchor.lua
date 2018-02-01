tide_anchor = class({})
LinkLuaModifier( "modifier_anchor", "heroes/hero_tide/tide_anchor.lua" ,LUA_MODIFIER_MOTION_NONE )

function tide_anchor:GetCastRange(target, position)
	return self:GetTalentSpecialValueFor("radius")
end

function tide_anchor:OnSpellStart()
    local caster = self:GetCaster()
    local point = caster:GetAbsOrigin()

    EmitSoundOn("Hero_Tidehunter.AnchorSmash", caster)

    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_tidehunter/tidehunter_anchor_hero.vpcf", PATTACH_POINT, caster)
    ParticleManager:SetParticleControl(nfx, 0, point)
    ParticleManager:ReleaseParticleIndex(nfx)
    
    local enemies = caster:FindEnemyUnitsInRadius(point, self:GetTalentSpecialValueFor("radius"), {})
    for _,enemy in pairs(enemies) do
        self:DealDamage(caster, enemy, self:GetTalentSpecialValueFor("damage"), {}, 0)
        enemy:AddNewModifier(caster, self, "modifier_anchor", {Duration = self:GetTalentSpecialValueFor("duration")})
    end

    local enemies = caster:FindEnemyUnitsInRadius(point, self:GetTalentSpecialValueFor("radius")/2, {})
    for _,enemy in pairs(enemies) do
        enemy:ApplyKnockBack(point, 0.25, 0.25, self:GetTalentSpecialValueFor("radius")/2, 0, caster, self)
    end
end

modifier_anchor = class({})
function modifier_anchor:DeclareFunctions()
    funcs = {MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE}
    return funcs
end

function modifier_anchor:GetModifierDamageOutgoing_Percentage()
    return self:GetTalentSpecialValueFor("damage_reduction")
end

function modifier_anchor:GetEffectName()
    return "particles/units/heroes/hero_tidehunter/tidehunter_gush_slow.vpcf"
end

function modifier_anchor:IsDebuff()
    return true
end
sb_haste = class({})
LinkLuaModifier( "modifier_sb_haste_aura", "heroes/hero_spirit_breaker/sb_haste.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sb_haste_aura_buff", "heroes/hero_spirit_breaker/sb_haste.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sb_haste_self", "heroes/hero_spirit_breaker/sb_haste.lua" ,LUA_MODIFIER_MOTION_NONE )

function sb_haste:IsStealable()
    return true
end

function sb_haste:IsHiddenWhenStolen()
    return false
end

function sb_haste:GetIntrinsicModifierName()
	return "modifier_sb_haste_aura"
end

function sb_haste:OnSpellStart()
	local caster = self:GetCaster()

	EmitSoundOn("Hero_Spirit_Breaker.EmpoweringHaste.Cast", caster)
    caster:AddNewModifier(caster, self, "modifier_sb_haste_self", {Duration = self:GetTalentSpecialValueFor("duration")})

    if caster:HasTalent("special_bonus_unique_sb_haste_2") then
    	local point = caster:GetAbsOrigin() + caster:GetForwardVector() * 54
    	local radius = 350

    	local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_vacuum.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControl(nfx, 0, point)
					ParticleManager:SetParticleControl(nfx, 1, Vector(radius, radius, radius))
					ParticleManager:SetParticleControl(nfx, 2, point)
					ParticleManager:ReleaseParticleIndex(nfx)

    	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius)
    	for _,enemy in pairs(enemies) do
    		FindClearSpaceForUnit(enemy, point, true)
    	end
    end
end

modifier_sb_haste_aura = class({})
function modifier_sb_haste_aura:IsAura()
    return true
end

function modifier_sb_haste_aura:GetAuraDuration()
    return 0.5
end

function modifier_sb_haste_aura:GetAuraRadius()
    return self:GetTalentSpecialValueFor("radius")
end

function modifier_sb_haste_aura:GetAuraEntityReject(handle)
    if handle == self:GetCaster() then
    	return false
    end
    return true
end

function modifier_sb_haste_aura:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_sb_haste_aura:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_sb_haste_aura:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_sb_haste_aura:GetModifierAura()
    return "modifier_sb_haste_aura_buff"
end

function modifier_sb_haste_aura:IsAuraActiveOnDeath()
    return false
end

function modifier_sb_haste_aura:IsHidden()
    return true
end

function modifier_sb_haste_aura:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }
    return funcs
end

function modifier_sb_haste_aura:GetModifierMoveSpeedBonus_Percentage()
    return self:GetTalentSpecialValueFor("bonus_ms_self")
end

function modifier_sb_haste_aura:GetMoveSpeedLimitBonus()
    return 99999
end

function modifier_sb_haste_aura:GetEffectName()
    return "particles/units/heroes/hero_spirit_breaker/spirit_breaker_haste_owner.vpcf"
end

function modifier_sb_haste_aura:IsPurgable()
    return false
end

modifier_sb_haste_aura_buff = class({})
function modifier_sb_haste_aura_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function modifier_sb_haste_aura_buff:GetModifierMoveSpeedBonus_Percentage()
    return self:GetTalentSpecialValueFor("bonus_ms_allies")
end

function modifier_sb_haste_aura_buff:IsHidden()
    return true
end

modifier_sb_haste_self = class({})
function modifier_sb_haste_self:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        
    }
    return funcs
end

function modifier_sb_haste_self:GetModifierMoveSpeedBonus_Percentage()
    return self:GetTalentSpecialValueFor("bonus_ms_extra")
end

function modifier_sb_haste_self:GetModifierAttackSpeedBonus()
	if self:GetCaster():HasTalent("special_bonus_unique_sb_haste_1") then
    	return self:GetTalentSpecialValueFor("bonus_ms_extra")
    end
    return 0
end

function modifier_sb_haste_self:IsDebuff()
    return false
end
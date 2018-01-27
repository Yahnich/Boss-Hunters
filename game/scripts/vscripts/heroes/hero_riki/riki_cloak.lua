riki_cloak = class({})
LinkLuaModifier( "modifier_cloak", "heroes/hero_riki/riki_cloak.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_cloak_speed", "heroes/hero_riki/riki_cloak.lua" ,LUA_MODIFIER_MOTION_NONE )

function riki_cloak:GetIntrinsicModifierName()
    return "modifier_cloak"
end

modifier_cloak = class({})
function modifier_cloak:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }   
    return funcs
end

function modifier_cloak:OnTakeDamage(params)
    if IsServer() then
        local caster = self:GetCaster()
        if params.unit == caster and self:GetAbility():IsCooldownReady() and not caster:HasModifier("modifier_invisible") then
            EmitSoundOn("Hero_Riki.Invisibility", caster)

            caster:AddNewModifier(caster, self:GetAbility(), "modifier_invisible", {Duration = self:GetTalentSpecialValueFor("duration")})
            caster:AddNewModifier(caster, self:GetAbility(), "modifier_cloak_speed", {Duration = self:GetTalentSpecialValueFor("duration")})

            if caster:HasScepter() and caster:HasModifier("modifier_invisible") then
                caster:AddNewModifier(caster, self:GetAbility(), "modifier_invulnerable", {Duration = self:GetTalentSpecialValueFor("duration")})
            end

            caster:SetThreat(0)
            self:GetAbility():StartCooldown(self:GetAbility():GetTrueCooldown())
        end

        if not caster:HasModifier("modifier_invisible") then
            caster:RemoveModifierByName("modifier_invulnerable")
            caster:RemoveModifierByName("modifier_cloak_speed")
        end
    end
end

function modifier_cloak:IsHidden()
    return true
end

modifier_cloak_speed = class({})
function modifier_cloak_speed:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }   
    return funcs
end

function modifier_cloak_speed:GetModifierMoveSpeedBonus_Percentage()
    return self:GetTalentSpecialValueFor("move_speed")
end

function modifier_cloak_speed:IsHidden()
    return true
end
riki_cloak = class({})
LinkLuaModifier( "modifier_cloak", "heroes/hero_riki/riki_cloak.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_cloak_speed", "heroes/hero_riki/riki_cloak.lua" ,LUA_MODIFIER_MOTION_NONE )

function riki_cloak:GetIntrinsicModifierName()
    return "modifier_cloak"
end

function riki_cloak:ShouldUseResources()
	return true
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
        if params.unit == caster and self:GetAbility():IsCooldownReady() and not caster:IsInvisible() then
            EmitSoundOn("Hero_Riki.Invisibility", caster)

            caster:AddNewModifier(caster, self:GetAbility(), "modifier_invisible", {Duration = self:GetSpecialValueFor("duration")})
            caster:AddNewModifier(caster, self:GetAbility(), "modifier_cloak_speed", {Duration = self:GetSpecialValueFor("duration")})

            if caster:HasScepter() and caster:HasModifier("modifier_invisible") then
                caster:AddNewModifier(caster, self:GetAbility(), "modifier_invulnerable", {Duration = self:GetSpecialValueFor("duration")})
            end

            caster:SetThreat(0)
            self:GetAbility():SetCooldown()
        end

        if not caster:IsInvisible() then
            caster:RemoveModifierByName("modifier_invulnerable")
            caster:RemoveModifierByName("modifier_cloak_speed")
        end
    end
end

function modifier_cloak:IsHidden()
    return true
end

modifier_cloak_speed = class({})
if IsServer() then
	function modifier_cloak_speed:OnCreated()
		self:GetAbility():StartDelayedCooldown()
	end
	function modifier_cloak_speed:OnRefresh()
		self:GetAbility():StartDelayedCooldown()
	end
	function modifier_cloak_speed:OnDestroy()
		self:GetAbility():EndDelayedCooldown()
	end
end

function modifier_cloak_speed:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }   
    return funcs
end

function modifier_cloak_speed:GetModifierMoveSpeedBonus_Percentage()
    return self:GetSpecialValueFor("move_speed")
end

function modifier_cloak_speed:IsHidden()
    return true
end
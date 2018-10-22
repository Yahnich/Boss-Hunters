sb_bash = class({})
LinkLuaModifier( "modifier_sb_bash_handle", "heroes/hero_spirit_breaker/sb_bash.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sb_bash_ms", "heroes/hero_spirit_breaker/sb_bash.lua" ,LUA_MODIFIER_MOTION_NONE )

function sb_bash:IsStealable()
    return true
end

function sb_bash:IsHiddenWhenStolen()
    return false
end

function sb_bash:GetIntrinsicModifierName()
	return "modifier_sb_bash_handle"
end

function sb_bash:Bash(target, distance)
    local caster = self:GetCaster()

    local stunDuration = self:GetTalentSpecialValueFor("duration")
    local knockbackDuration = self:GetTalentSpecialValueFor("knockback_duration")
    local height = self:GetTalentSpecialValueFor("knockback_height")

    local dist = distance

    local damage = caster:GetMoveSpeedModifier(caster:GetBaseMoveSpeed()) * self:GetTalentSpecialValueFor("damage")/100

    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_spirit_breaker/spirit_breaker_greater_bash.vpcf", PATTACH_POINT, caster)
                ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
                ParticleManager:SetParticleControlForward(nfx, 1, caster:GetForwardVector())
                ParticleManager:SetParticleControl(nfx, 2, caster:GetAbsOrigin())
                ParticleManager:ReleaseParticleIndex(nfx)                

    if caster:HasTalent("special_bonus_unique_sb_bash_1") then
        dist = 1
    end

    EmitSoundOn("Hero_Spirit_Breaker.GreaterBash.Creep", target)

    target:ApplyKnockBack(caster:GetAbsOrigin(), knockbackDuration, knockbackDuration, dist, height, caster, self)

    Timers:CreateTimer(knockbackDuration, function()
        if caster:HasTalent("special_bonus_unique_sb_bash_2") then
            target:Daze(self, caster, stunDuration)
        else
            self:Stun(target, stunDuration, false)
        end
    end)

    caster:AddNewModifier(caster, self, "modifier_sb_bash_ms", {Duration = self:GetTalentSpecialValueFor("ms_duration")})
    self:DealDamage(caster, target, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
end

modifier_sb_bash_handle = class({})

function modifier_sb_bash_handle:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
    return funcs
end

function modifier_sb_bash_handle:OnAttackLanded(params)
    local caster = self:GetCaster()
    local attacker = params.attacker
    local target = params.target
    local ability = self:GetAbility()

    if attacker == caster and ability:IsCooldownReady() then
        if self:RollPRNG( self:GetTalentSpecialValueFor("chance") ) then
            local distance = self:GetTalentSpecialValueFor("knockback_distance")
            ability:Bash(target, distance)
            ability:SetCooldown()
        end
    end
end

function modifier_sb_bash_handle:IsHidden()
    return true
end

modifier_sb_bash_ms = class({})
function modifier_sb_bash_ms:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
    return funcs
end

function modifier_sb_bash_ms:GetModifierMoveSpeedBonus_Percentage()
    return self:GetTalentSpecialValueFor("bonus_ms")
end

function modifier_sb_bash_ms:IsDebuff()
    return false
end

function modifier_sb_bash_ms:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end
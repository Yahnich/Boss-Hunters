druid_bear_entangle = class({})
LinkLuaModifier("modifier_druid_bear_entangle", "heroes/hero_lone_druid/druid_bear_entangle", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_druid_bear_entangle_enemy", "heroes/hero_lone_druid/druid_bear_entangle", LUA_MODIFIER_MOTION_NONE)

function druid_bear_entangle:IsStealable()
    return false
end

function druid_bear_entangle:IsHiddenWhenStolen()
    return false
end

function druid_bear_entangle:GetIntrinsicModifierName()
    return "modifier_druid_bear_entangle"
end

modifier_druid_bear_entangle = class({})
function modifier_druid_bear_entangle:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
    return funcs
end

function modifier_druid_bear_entangle:OnAttackLanded(params)
    if IsServer() then
        if not self:GetParent():PassivesDisabled() then
            if params.attacker == self:GetParent() and RollPercentage(self:GetTalentSpecialValueFor("chance")) and params.target:IsAlive() and not params.target:IsMagicImmune() and self:GetAbility():IsCooldownReady() then
                self:GetAbility():SetCooldown()
                params.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_druid_bear_entangle_enemy", {Duration = self:GetTalentSpecialValueFor("duration")})
            end
        end
    end
end

function modifier_druid_bear_entangle:IsHidden()
    return true
end

modifier_druid_bear_entangle_enemy = class({})
function modifier_druid_bear_entangle_enemy:OnCreated(table)
    if IsServer() then
        EmitSoundOn("LoneDruid_SpiritBear.Entangle", self:GetParent())

        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_bear_entangle.vpcf", PATTACH_POINT, self:GetCaster()) 
                    ParticleManager:SetParticleControlEnt(nfx, 0, self:GetParent(), PATTACH_ABSORIGIN, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)

        self:AttachEffect(nfx)

        self:StartIntervalThink(1.0)
    end
end

function modifier_druid_bear_entangle_enemy:OnRemoved()
    if IsServer() then
        StopSoundOn("LoneDruid_SpiritBear.Entangle", self:GetParent())
    end
end

function modifier_druid_bear_entangle_enemy:OnIntervalThink()
    local caster = self:GetCaster()
    local parent = self:GetParent()

    if not caster then
        self:Destroy()
    end

    local damage = 0

    if caster:IsHero() then
        damage = caster:GetIntellect() * (self:GetTalentSpecialValueFor("int_damage")/100)
    elseif caster:GetOwnerEntity() then
        damage = caster:GetOwnerEntity():GetIntellect() * (self:GetTalentSpecialValueFor("int_damage")/100)
    end

    self:GetAbility():DealDamage(caster, parent, damage, {}, OVERHEAD_ALERT_BONUS_POISON_DAMAGE)
end

function modifier_druid_bear_entangle_enemy:GetEffectName()
    return "particles/units/heroes/hero_lone_druid/lone_druid_bear_entangle_body.vpcf"
end

function modifier_druid_bear_entangle_enemy:CheckState()
    local state = { [MODIFIER_STATE_ROOTED] = true}
    return state
end

function modifier_druid_bear_entangle_enemy:IsDebuff()
    return true
end

function modifier_druid_bear_entangle_enemy:IsPurgable()
    return true
end
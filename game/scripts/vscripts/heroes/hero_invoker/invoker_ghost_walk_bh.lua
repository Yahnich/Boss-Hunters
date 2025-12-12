invoker_ghost_walk_bh = class({})
LinkLuaModifier("modifier_invoker_ghost_walk_bh", "heroes/hero_invoker/invoker_ghost_walk_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_invoker_ghost_walk_bh_enemy", "heroes/hero_invoker/invoker_ghost_walk_bh", LUA_MODIFIER_MOTION_NONE)

function invoker_ghost_walk_bh:IsStealable()
    return true
end

function invoker_ghost_walk_bh:IsHiddenWhenStolen()
    return false
end

function invoker_ghost_walk_bh:OnAbilityPhaseStart()
    self:GetCaster():StartGesture(ACT_DOTA_CAST_GHOST_WALK)
    return true
end

function invoker_ghost_walk_bh:OnAbilityPhaseInterrupted()
    self:GetCaster():RemoveGesture(ACT_DOTA_CAST_GHOST_WALK)
end

function invoker_ghost_walk_bh:OnSpellStart()
    local caster = self:GetCaster()

    local duration = self:GetSpecialValueFor("duration")

    caster:AddNewModifier(caster, self, "modifier_invoker_ghost_walk_bh", {Duration = duration})
end

modifier_invoker_ghost_walk_bh = class({})
function modifier_invoker_ghost_walk_bh:OnCreated(table)
    local caster = self:GetCaster()

    self.self_slow = self:GetSpecialValueFor("self_slow")

    self.enemy_slow_duration = self:GetSpecialValueFor("aura_fade_time")

    self.radius = self:GetSpecialValueFor("radius")

    ParticleManager:FireParticle("particles/units/heroes/hero_invoker/invoker_ghost_walk.vpcf", PATTACH_POINT, caster, {})
end

function modifier_invoker_ghost_walk_bh:OnRefresh(table)
    local caster = self:GetCaster()

    self.self_slow = self:GetSpecialValueFor("self_slow")

    self.enemy_slow_duration = self:GetSpecialValueFor("aura_fade_time")

    self.radius = self:GetSpecialValueFor("radius")
end

function modifier_invoker_ghost_walk_bh:IsAura()
    return true
end

function modifier_invoker_ghost_walk_bh:GetAuraDuration()
    return self.enemy_slow_duration
end

function modifier_invoker_ghost_walk_bh:GetAuraRadius()
    return self.radius
end

function modifier_invoker_ghost_walk_bh:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_invoker_ghost_walk_bh:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_invoker_ghost_walk_bh:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_invoker_ghost_walk_bh:GetModifierAura()
    return "modifier_invoker_ghost_walk_bh_enemy"
end

function modifier_invoker_ghost_walk_bh:DeclareFunctions()
    return {MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
            MODIFIER_EVENT_ON_ATTACK,
            MODIFIER_EVENT_ON_ABILITY_EXECUTED,
            MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_invoker_ghost_walk_bh:GetModifierInvisibilityLevel()
    return 1
end

function modifier_invoker_ghost_walk_bh:OnAttack(params)
    if IsServer() then
        if params.attacker == self:GetParent() then
            self:Destroy()
        end
    end
end

function modifier_invoker_ghost_walk_bh:OnAbilityExecuted(params)
    if IsServer() then
        if params.unit == self:GetParent() then
            self:Destroy()
        end
    end
end

function modifier_invoker_ghost_walk_bh:GetModifierMoveSpeedBonus_Percentage()
    return self.self_slow
end

function modifier_invoker_ghost_walk_bh:CheckState()
    local state = { [MODIFIER_STATE_INVISIBLE] = true, 
                    [MODIFIER_STATE_NO_UNIT_COLLISION] = true}
    return state
end

function modifier_invoker_ghost_walk_bh:IsDebuff()
    return false
end

function modifier_invoker_ghost_walk_bh:IsPurgable()
    return false
end

modifier_invoker_ghost_walk_bh_enemy = class({})
function modifier_invoker_ghost_walk_bh_enemy:OnCreated(table)
    local caster = self:GetCaster()

    self.enemy_slow = self:GetSpecialValueFor("enemy_slow")
end

function modifier_invoker_ghost_walk_bh_enemy:OnRefresh(table)
    local caster = self:GetCaster()

    self.enemy_slow = self:GetSpecialValueFor("enemy_slow")
end

function modifier_invoker_ghost_walk_bh_enemy:DeclareFunctions()
    return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_invoker_ghost_walk_bh_enemy:GetModifierMoveSpeedBonus_Percentage()
    return self.enemy_slow
end

function modifier_invoker_ghost_walk_bh_enemy:GetEffectName()
    return "particles/units/heroes/hero_invoker/invoker_ghost_walk_debuff.vpcf"
end

function modifier_invoker_ghost_walk_bh_enemy:IsDebuff()
    return true
end

function modifier_invoker_ghost_walk_bh_enemy:IsPurgable()
    return false
end
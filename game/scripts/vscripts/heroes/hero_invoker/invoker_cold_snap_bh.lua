invoker_cold_snap_bh = class({})
LinkLuaModifier("modifier_invoker_cold_snap_bh_cooldown", "heroes/hero_invoker/invoker_cold_snap_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_invoker_cold_snap_bh", "heroes/hero_invoker/invoker_cold_snap_bh", LUA_MODIFIER_MOTION_NONE)

function invoker_cold_snap_bh:IsStealable()
    return true
end

function invoker_cold_snap_bh:IsHiddenWhenStolen()
    return false
end

function invoker_cold_snap_bh:OnAbilityPhaseStart()
    self:GetCaster():StartGesture(ACT_DOTA_CAST_COLD_SNAP)
    return true
end

function invoker_cold_snap_bh:OnAbilityPhaseInterrupted()
    self:GetCaster():RemoveGesture(ACT_DOTA_CAST_COLD_SNAP)
end

function invoker_cold_snap_bh:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    local duration = self:GetSpecialValueFor("duration")

    local freeze_duration = self:GetSpecialValueFor("freeze_duration")
    local freeze_cooldown = self:GetSpecialValueFor("freeze_cooldown")
    local freeze_damage = self:GetSpecialValueFor("freeze_damage")

    local cooldown_modifier = "modifier_invoker_cold_snap_bh_cooldown"
    local cold_snap_modifier = "modifier_invoker_cold_snap_bh"

    target:AddNewModifier(caster, self, cold_snap_modifier, {Duration = duration})
    target:AddNewModifier(caster, self, cooldown_modifier, {Duration = freeze_cooldown})

    target:Freeze(self, caster, freeze_duration)

    self:DealDamage(caster, target, freeze_damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
end

modifier_invoker_cold_snap_bh = class({})
function modifier_invoker_cold_snap_bh:OnCreated(table)
    if IsServer() then
        local caster = self:GetCaster()

        self.duration = self:GetSpecialValueFor("duration")

        self.freeze_duration = self:GetSpecialValueFor("freeze_duration")
        self.freeze_cooldown = self:GetSpecialValueFor("freeze_cooldown")
        self.freeze_damage = self:GetSpecialValueFor("freeze_damage")

        self.cooldown_modifier = "modifier_invoker_cold_snap_bh_cooldown"
        self.cold_snap_modifier = "modifier_invoker_cold_snap_bh"
    end
end

function modifier_invoker_cold_snap_bh:OnRefresh(table)
    if IsServer() then
        local caster = self:GetCaster()

        self.duration = self:GetSpecialValueFor("duration")

        self.freeze_duration = self:GetSpecialValueFor("freeze_duration")
        self.freeze_cooldown = self:GetSpecialValueFor("freeze_cooldown")
        self.freeze_damage = self:GetSpecialValueFor("freeze_damage")

        self.cooldown_modifier = "modifier_invoker_cold_snap_bh_cooldown"
        self.cold_snap_modifier = "modifier_invoker_cold_snap_bh"
    end
end

function modifier_invoker_cold_snap_bh:DeclareFunctions()
    local funcs = { MODIFIER_EVENT_ON_TAKEDAMAGE }
    return funcs
end

function modifier_invoker_cold_snap_bh:OnTakeDamage(params)
    if IsServer() then
        local caster = self:GetCaster()
        local parent = self:GetParent()
        local unit = params.unit

        if unit == parent then
            if not unit:HasModifier(self.cooldown_modifier) then
                --unit:AddNewModifier(caster, self:GetAbility(), self.cold_snap_modifier, {Duration = self.duration})
                unit:AddNewModifier(caster, self:GetAbility(), self.cooldown_modifier, {Duration = self.freeze_cooldown})

                unit:Freeze(self:GetAbility(), caster, self.freeze_duration)

                self:GetAbility():DealDamage(caster, unit, self.freeze_damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
            end
        end
    end
end

function modifier_invoker_cold_snap_bh:IsDebuff()
    return true
end

function modifier_invoker_cold_snap_bh:IsPurgable()
    return true
end

modifier_invoker_cold_snap_bh_cooldown = class({})

function modifier_invoker_cold_snap_bh_cooldown:IsHidden()
    return true
end

function modifier_invoker_cold_snap_bh_cooldown:IsPurgable()
    return false
end
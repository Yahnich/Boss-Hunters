lifestealer_assimilate_bh = class({})
LinkLuaModifier("modifier_lifestealer_assimilate_bh", "heroes/hero_lifestealer/lifestealer_assimilate_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lifestealer_assimilate_bh_ally", "heroes/hero_lifestealer/lifestealer_assimilate_bh", LUA_MODIFIER_MOTION_NONE)

function lifestealer_assimilate_bh:IsStealable()
    return false
end

function lifestealer_assimilate_bh:IsHiddenWhenStolen()
    return false
end

function lifestealer_assimilate_bh:GetCastPoint()
    if self:GetCaster():HasModifier("modifier_lifestealer_assimilate_bh") then
        return 0
    else
        return 0.2
    end
end

function lifestealer_assimilate_bh:GetCastAnimation()
    if self:GetCaster():HasModifier("modifier_lifestealer_assimilate_bh") then
        return ACT_DOTA_LIFESTEALER_EJECT
    else
        return ACT_DOTA_LIFESTEALER_ASSIMILATE
    end
end

function lifestealer_assimilate_bh:GetBehavior()
    if self:GetCaster():HasScepter() then
        if self:GetCaster():HasModifier("modifier_lifestealer_assimilate_bh") then
            return DOTA_ABILITY_BEHAVIOR_NO_TARGET
        else
            return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
        end
    else
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_HIDDEN
    end
end

function lifestealer_assimilate_bh:OnInventoryContentsChanged()
    if self:GetCaster():HasScepter() then
        self:SetLevel(1)
        self:SetHidden(false)
        self:SetActivated(true)
    else
        if self.target then
            self.target:RemoveModifierByName("modifier_lifestealer_assimilate_bh_ally")
        end
        self:SetLevel(0)
        self:SetHidden(true)
        self:SetActivated(false)
    end
end

function lifestealer_assimilate_bh:OnOwnerDied()
    if self.target then
        self.target:RemoveModifierByName("modifier_lifestealer_assimilate_bh_ally")
    end
end

function lifestealer_assimilate_bh:OnSpellStart()
    local caster = self:GetCaster()

    if caster:HasModifier("modifier_lifestealer_assimilate_bh") then
        if self.target then
            self.target:RemoveModifierByName("modifier_lifestealer_assimilate_bh_ally")
        end
        self:RefundManaCost()
        self:SetCooldown()
    else
        self.target = self:GetCursorTarget()
        if self.target ~= caster and not self.target:HasModifier("modifier_lifestealer_infest_bh_ally") then
            ParticleManager:FireParticle("particles/units/heroes/hero_life_stealer/life_stealer_loadout.vpcf", PATTACH_POINT, caster, {[0]=self.target:GetAbsOrigin(), [1]=caster:GetAbsOrigin()})
            caster:AddNewModifier(caster, self, "modifier_lifestealer_assimilate_bh", {})
            self.target:AddNewModifier(caster, self, "modifier_lifestealer_assimilate_bh_ally", {})
        else
            self:RefundManaCost()
        end
        self:EndCooldown()
    end
end

function lifestealer_assimilate_bh:GetCastRange(location, target)
    return self:GetCaster():GetAttackRange()
end

modifier_lifestealer_assimilate_bh = class({})

function modifier_lifestealer_assimilate_bh:DeclareFunctions()
    return {MODIFIER_EVENT_ON_HEALTH_GAINED}
end

function modifier_lifestealer_assimilate_bh:OnHealthGained(params)
    if IsServer() then
        if params.unit == self:GetParent() then
            --print(params.gain)
            self:GetAbility().target:HealEvent(params.gain, self:GetAbility(), self:GetCaster(), false)
        end
    end
end

function modifier_lifestealer_assimilate_bh:GetEffectName()
    return "particles/units/heroes/hero_life_stealer/life_stealer_infested_unit.vpcf"
end

function modifier_lifestealer_assimilate_bh:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_lifestealer_assimilate_bh:IsDebuff()
    return false
end

modifier_lifestealer_assimilate_bh_ally = class({})

function modifier_lifestealer_assimilate_bh_ally:OnCreated()
    if IsServer() then
        local ability = self:GetParent():AddAbility("lifestealer_assimilate_exit")
        ability:SetLevel(1)
        ability:SetHidden(false)
        ability:SetActivated(true)
        self:GetParent():AddNoDraw()
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_lifestealer_assimilate_bh_ally:OnRemoved()
    if IsServer() then
        self:GetParent():RemoveAbility("lifestealer_assimilate_exit")
        self:GetParent():RemoveNoDraw()
        ParticleManager:FireParticle("particles/units/heroes/hero_life_stealer/life_stealer_infest_emerge_bloody.vpcf", PATTACH_POINT, self:GetCaster(), {[0]=self:GetCaster():GetAbsOrigin()})
        FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), false)
        local enemies = self:GetCaster():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetSpecialValueFor("radius"))
        for _,enemy in pairs(enemies) do
            self:GetAbility():DealDamage(self:GetCaster(), enemy, self:GetSpecialValueFor("damage"), {}, 0)
        end
        self:GetCaster():RemoveModifierByName("modifier_lifestealer_assimilate_bh")
    end
end

function modifier_lifestealer_assimilate_bh_ally:OnIntervalThink()
    self:GetParent():SetAbsOrigin(self:GetCaster():GetAbsOrigin())
end

function modifier_lifestealer_assimilate_bh_ally:CheckState()
    local state = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                    [MODIFIER_STATE_ROOTED] = true,
                    [MODIFIER_STATE_INVULNERABLE] = true}
    return state
end

function modifier_lifestealer_assimilate_bh_ally:IsDebuff()
    return false
end
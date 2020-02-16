lifestealer_infest_bh = class({})
LinkLuaModifier("modifier_lifestealer_infest_bh", "heroes/hero_lifestealer/lifestealer_infest_bh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_lifestealer_infest_bh_ally", "heroes/hero_lifestealer/lifestealer_infest_bh", LUA_MODIFIER_MOTION_NONE)

function lifestealer_infest_bh:IsStealable()
    return false
end

function lifestealer_infest_bh:IsHiddenWhenStolen()
    return false
end

function lifestealer_infest_bh:GetCastPoint()
    if self:GetCaster():HasModifier("modifier_lifestealer_infest_bh") then
        return 0
    else
        return 0.2
    end
end

function lifestealer_infest_bh:GetCastAnimation()
    if self:GetCaster():HasModifier("modifier_lifestealer_infest_bh") then
        return ACT_DOTA_LIFESTEALER_INFEST
    else
        return ACT_DOTA_LIFESTEALER_INFEST_END
    end
end

function lifestealer_infest_bh:GetBehavior()
    if self:GetCaster():HasModifier("modifier_lifestealer_infest_bh") then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET
    else
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
    end
end

function lifestealer_infest_bh:OnOwnerDied()
    if self.target then
        self.target:RemoveModifierByName("modifier_lifestealer_infest_bh_ally")
    end
end

function lifestealer_infest_bh:OnSpellStart()
    local caster = self:GetCaster()

    if caster:HasModifier("modifier_lifestealer_infest_bh") then
        caster:RemoveModifierByName("modifier_lifestealer_infest_bh")
        self:RefundManaCost()
    else
        self.target = self:GetCursorTarget()
        if self.target ~= caster and not self.target:HasModifier("modifier_lifestealer_assimilate_bh_ally") then
            ParticleManager:FireParticle("particles/units/heroes/hero_life_stealer/life_stealer_loadout.vpcf", PATTACH_POINT, self.target, {[0]=caster:GetAbsOrigin(), [1]=self.target:GetAbsOrigin()})
            caster:AddNewModifier(caster, self, "modifier_lifestealer_infest_bh", {})
            self.target:AddNewModifier(caster, self, "modifier_lifestealer_infest_bh_ally", {})
        else
            self:RefundManaCost()
        end
        self:EndCooldown()
    end
end

function lifestealer_infest_bh:GetCastRange(location, target)
    return self:GetCaster():GetAttackRange()
end

modifier_lifestealer_infest_bh = class({})

function modifier_lifestealer_infest_bh:OnCreated()
    if IsServer() then
		self.target = self:GetAbility():GetCursorTarget()
        self:GetParent():AddNoDraw()
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_lifestealer_infest_bh:OnRemoved()
    if IsServer() then
        self:GetParent():RemoveNoDraw()
        ParticleManager:FireParticle("particles/units/heroes/hero_life_stealer/life_stealer_infest_emerge_bloody.vpcf", PATTACH_POINT, self:GetAbility().target, {[0]=self:GetAbility().target:GetAbsOrigin()})
        FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), false)
        local enemies = self:GetParent():FindEnemyUnitsInRadius(self:GetParent():GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"))
        for _,enemy in pairs(enemies) do
            local damage = self:GetCaster():GetMaxHealth() * self:GetTalentSpecialValueFor("damage")/100
            self:GetAbility():DealDamage(self:GetParent(), enemy, self:GetTalentSpecialValueFor("damage"), {damage_flags=DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, 0)
        end
        self:GetAbility().target:RemoveModifierByName("modifier_lifestealer_infest_bh_ally")
		self:GetAbility():SetCooldown()
    end
end

function modifier_lifestealer_infest_bh:OnIntervalThink()
	if self:GetAbility().target and self:GetAbility().target:IsAlive() then
		self:GetCaster():SetAbsOrigin(self:GetAbility().target:GetAbsOrigin())
	else
		self:Destroy()
	end
end

function modifier_lifestealer_infest_bh:CheckState()
    local state = { [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
                    [MODIFIER_STATE_ROOTED] = true,
                    [MODIFIER_STATE_DISARMED] = true,
                    [MODIFIER_STATE_INVULNERABLE] = true}
    return state
end

function modifier_lifestealer_infest_bh:IsDebuff()
    return false
end

modifier_lifestealer_infest_bh_ally = class({})

function modifier_lifestealer_infest_bh_ally:IsDebuff()
    return false
end

function modifier_lifestealer_infest_bh_ally:GetEffectName()
    return "particles/units/heroes/hero_life_stealer/life_stealer_infested_unit.vpcf"
end

function modifier_lifestealer_infest_bh_ally:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end
snapfire_scatterblast_lua = class({})
LinkLuaModifier("modifier_snapfire_scatterblast_lua_slow", "heroes/hero_snapfire/snapfire_scatterblast_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_snapfire_scatterblast_lua_talent", "heroes/hero_snapfire/snapfire_scatterblast_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_snapfire_scatterblast_lua_disarm", "heroes/hero_snapfire/snapfire_scatterblast_lua", LUA_MODIFIER_MOTION_NONE)

function snapfire_scatterblast_lua:IsStealable()
    return true
end

function snapfire_scatterblast_lua:IsHiddenWhenStolen()
    return false
end

function snapfire_scatterblast_lua:GetIntrinsicModifierName()
    return "modifier_snapfire_scatterblast_lua_talent"
end

function snapfire_scatterblast_lua:OnAbilityPhaseStart()
    EmitSoundOn("Hero_Snapfire.Shotgun.Load", self:GetCaster())
    return true
end

function snapfire_scatterblast_lua:OnAbilityPhaseInterrupted()
    StopSoundOn("Hero_Snapfire.Shotgun.Load", self:GetCaster())
end

function snapfire_scatterblast_lua:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    
    local direction = CalculateDirection(point, caster:GetAbsOrigin())
    local speed = self:GetTalentSpecialValueFor("blast_speed")
    local velocity = direction * speed
    local distance = self:GetTrueCastRange() --self:GetCastRange(point, caster)
    local start_width = self:GetTalentSpecialValueFor("blast_width_initial")
    local end_width = self:GetTalentSpecialValueFor("blast_width_end")

    EmitSoundOn("Hero_Snapfire.Shotgun.Fire", self:GetCaster())

    self:FireLinearProjectile("particles/units/heroes/hero_snapfire/hero_snapfire_shotgun.vpcf", velocity, distance, start_width, {width_end = end_width, extraData = {name = "majorblast"}}, false, false, 0)
end

function snapfire_scatterblast_lua:OnProjectileHit_ExtraData(hTarget, vLocation, table)
    local caster = self:GetCaster()

    local damage = self:GetTalentSpecialValueFor("damage")
    local point_blank_range = self:GetTalentSpecialValueFor("point_blank_range")
    local point_blank_dmg_bonus_pct = self:GetTalentSpecialValueFor("point_blank_dmg_bonus_pct")/100
    local point_blank_knock_back = self:GetTalentSpecialValueFor("point_blank_knock_back")

    local debuff_duration = self:GetTalentSpecialValueFor("debuff_duration")

    local talentDamage = caster:FindTalentValue("special_bonus_unique_snapfire_scatterblast_lua_2", "damage")/100

    if hTarget ~= nil then
		if table.name == "majorblast" and hTarget:TriggerSpellAbsorb( self ) then return end
        EmitSoundOn("Hero_Snapfire.Shotgun.Target ", hTarget)

        hTarget:AddNewModifier(caster, self, "modifier_snapfire_scatterblast_lua_slow", {Duration = debuff_duration})

        if CalculateDistance(hTarget, caster) < point_blank_range then
            ParticleManager:FireParticle("particles/units/heroes/hero_snapfire/hero_snapfire_shotgun_impact.vpcf", PATTACH_ABSORIGIN, hTarget, {})
            damage = damage * point_blank_dmg_bonus_pct + damage

            if table.name == "majorblast" then
                hTarget:ApplyKnockBack(vLocation, 0.1, 0.1, point_blank_knock_back, 0, caster, self, true)
            end
        end

        if table.name == "minorblast" then
            damage = damage * talentDamage
        end

        if caster:HasTalent("special_bonus_unique_snapfire_scatterblast_lua_1") then
            local disarm_duration = caster:FindTalentValue("special_bonus_unique_snapfire_scatterblast_lua_1")
            hTarget:AddNewModifier(caster, self, "modifier_snapfire_scatterblast_lua_disarm", {Duration = disarm_duration})
        end

        self:DealDamage(caster, hTarget, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
    end
end

modifier_snapfire_scatterblast_lua_slow = class({})

function modifier_snapfire_scatterblast_lua_slow:OnCreated(table)
    self.slow = -self:GetTalentSpecialValueFor("movement_slow_pct")

    if IsServer() then
        ParticleManager:FireParticle("particles/units/heroes/hero_snapfire/hero_snapfire_shotgun_slow.vpcf", PATTACH_ABSORIGIN, self:GetParent(), {})
    end
end

function modifier_snapfire_scatterblast_lua_slow:OnRefresh(table)
    self.slow = -self:GetTalentSpecialValueFor("movement_slow_pct")

    if IsServer() then
        ParticleManager:FireParticle("particles/units/heroes/hero_snapfire/hero_snapfire_shotgun_slow.vpcf", PATTACH_ABSORIGIN, self:GetParent(), {})
    end
end

function modifier_snapfire_scatterblast_lua_slow:DeclareFunctions()
    local funcs = {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
    return funcs
end

function modifier_snapfire_scatterblast_lua_slow:GetModifierMoveSpeedBonus_Percentage()
    return self.slow
end

function modifier_snapfire_scatterblast_lua_slow:GetEffectName()
    return "particles/units/heroes/hero_snapfire/hero_snapfire_shotgun_debuff.vpcf"
end

function modifier_snapfire_scatterblast_lua_slow:IsPurgable()
    return true
end

function modifier_snapfire_scatterblast_lua_slow:IsDebuff()
    return true
end

modifier_snapfire_scatterblast_lua_talent = class({})

function modifier_snapfire_scatterblast_lua_talent:OnCreated(table)
    if IsServer() then 
        local parent = self:GetParent()

        self.chance = parent:FindTalentValue("special_bonus_unique_snapfire_scatterblast_lua_2", "chance")
        self.distance = self:GetAbility():GetTrueCastRange()
        self.start_width = self:GetTalentSpecialValueFor("blast_width_initial")
        self.end_width = self:GetTalentSpecialValueFor("blast_width_end")
        self.speed = self:GetTalentSpecialValueFor("blast_speed")

        self:StartIntervalThink(1)
    end
end

function modifier_snapfire_scatterblast_lua_talent:OnIntervalThink()
    self.chance = self:GetParent():FindTalentValue("special_bonus_unique_snapfire_scatterblast_lua_2", "chance")
end

function modifier_snapfire_scatterblast_lua_talent:DeclareFunctions()
    local funcs = {MODIFIER_EVENT_ON_ATTACK_LANDED}
    return funcs
end

function modifier_snapfire_scatterblast_lua_talent:OnAttackLanded(params)
    if IsServer() then
        local parent = self:GetParent()
        local attacker = params.attacker
        local target = params.target

        if parent:HasTalent("special_bonus_unique_snapfire_scatterblast_lua_2") then
            if target and target ~= attacker and target:GetTeam() ~= attacker:GetTeam()
             and attacker == parent then
                local direction = CalculateDirection(target, attacker)
                local velocity = direction * self.speed

                if RollPRNGFormula( attacker, self.chance ) then
                    EmitSoundOn("Hero_Snapfire.Shotgun.Fire", parent)

                    self:GetAbility():FireLinearProjectile("particles/units/heroes/hero_snapfire/hero_snapfire_shotgun.vpcf", velocity, self.distance, self.start_width, {width_end = self.end_width, extraData = {name = "minorblast"}}, false, false, 0)
                end
            end
        end
    end
end

function modifier_snapfire_scatterblast_lua_talent:IsPurgable()
    return false
end

function modifier_snapfire_scatterblast_lua_talent:IsDebuff()
    return false
end

function modifier_snapfire_scatterblast_lua_talent:IsHidden()
    return true
end

modifier_snapfire_scatterblast_lua_disarm = class({})

function modifier_snapfire_scatterblast_lua_disarm:CheckState()
    return {[MODIFIER_STATE_DISARMED] = true }
end

function modifier_snapfire_scatterblast_lua_disarm:GetEffectName()
    return "particles/units/heroes/hero_snapfire/hero_snapfire_disarm.vpcf"
end

function modifier_snapfire_scatterblast_lua_disarm:GetEffectAttachType()
    return PATTACH_OVERHEAD_FOLLOW
end

function modifier_snapfire_scatterblast_lua_disarm:IsPurgable()
    return true
end

function modifier_snapfire_scatterblast_lua_disarm:IsDebuff()
    return true
end
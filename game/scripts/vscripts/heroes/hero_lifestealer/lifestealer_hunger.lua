lifestealer_hunger = class({})
LinkLuaModifier( "modifier_lifestealer_hunger", "heroes/hero_lifestealer/lifestealer_hunger.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_lifestealer_hunger_active", "heroes/hero_lifestealer/lifestealer_hunger.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_lifestealer_hunger_handle", "heroes/hero_lifestealer/lifestealer_hunger.lua" ,LUA_MODIFIER_MOTION_NONE )

function lifestealer_hunger:GetBehavior()
    if self:GetCaster():HasTalent("special_bonus_unique_lifestealer_hunger_2") then
        return DOTA_ABILITY_BEHAVIOR_NO_TARGET
    else
        return DOTA_ABILITY_BEHAVIOR_PASSIVE
    end
end

function lifestealer_hunger:GetCooldown(iLevel)
    if self:GetCaster():HasTalent("special_bonus_unique_lifestealer_hunger_2") then
        return 25
    else
        return 0
    end
end

function lifestealer_hunger:OnSpellStart()
    local caster = self:GetCaster()

    caster:RemoveModifierByName("modifier_lifestealer_hunger")
    caster:AddNewModifier(caster, self, "modifier_lifestealer_hunger_active", {Duration = caster:FindTalentValue("special_bonus_unique_lifestealer_hunger_2")})
end

function lifestealer_hunger:GetIntrinsicModifierName()
    return "modifier_lifestealer_hunger_handle"
end

modifier_lifestealer_hunger_handle = class({})
function modifier_lifestealer_hunger_handle:OnCreated(table)
    if IsServer() then
        self:StartIntervalThink(0.1)
    end
end

function modifier_lifestealer_hunger_handle:OnIntervalThink()
    local caster = self:GetCaster()
    if not caster:HasModifier("modifier_lifestealer_hunger_active") and not caster:HasModifier("modifier_lifestealer_hunger") then
        caster:AddNewModifier(caster, self:GetAbility(), "modifier_lifestealer_hunger", {})
    end
end

function modifier_lifestealer_hunger_handle:IsHidden()
    return true
end

modifier_lifestealer_hunger = class({})

function modifier_lifestealer_hunger:OnCreated()
    self.radius = self:GetAbility():GetTalentSpecialValueFor("radius")
    self.maxdamage = self:GetAbility():GetTalentSpecialValueFor("max_damage_amp")
    self.mindamage = self:GetAbility():GetTalentSpecialValueFor("max_lifesteal") / 100
    self.maxlifesteal = self:GetAbility():GetTalentSpecialValueFor("min_damage_amp")
    self.minlifesteal = self:GetAbility():GetTalentSpecialValueFor("min_lifesteal") / 100
    self.currentlifesteal = self.minlifesteal
    self:SetStackCount(self.mindamage)
    if IsServer() then
        self:StartIntervalThink(0.1)
    end
end

function modifier_lifestealer_hunger:OnRefresh()
    self.radius = self:GetAbility():GetTalentSpecialValueFor("radius")
    self.maxdamage = self:GetAbility():GetTalentSpecialValueFor("max_damage_amp")
    self.maxlifesteal = self:GetAbility():GetTalentSpecialValueFor("max_lifesteal") / 100
    self.mindamage = self:GetAbility():GetTalentSpecialValueFor("min_damage_amp")
    self.minlifesteal = self:GetAbility():GetTalentSpecialValueFor("min_lifesteal") / 100
    self.currentlifesteal = self.minlifesteal
end

function modifier_lifestealer_hunger:OnIntervalThink()
    local allUnits = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
    local maxHP = 1
    for _,unit in pairs(allUnits) do
        maxHP = maxHP + unit:GetMaxHealth()
    end
    local hungerUnits = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false)
    local currHP = 0
    for _,unit in pairs(hungerUnits) do
        currHP = currHP + unit:GetHealth()
    end
    local diffDmg = self.maxdamage - self.mindamage
    local diffLs = self.maxlifesteal - self.minlifesteal
    local newStacks = math.floor(self.mindamage + diffDmg * currHP/maxHP)
    self.currentlifesteal = self.minlifesteal + diffLs * currHP/maxHP
    self:SetStackCount(newStacks)
end

function modifier_lifestealer_hunger:DeclareFunctions()
    funcs = {
                MODIFIER_EVENT_ON_ATTACK_LANDED,
                MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
            }
    return funcs
end

function modifier_lifestealer_hunger:OnAttackLanded(params)
    if IsServer() then
        if params.attacker == self:GetParent() then
            local flHeal = params.original_damage * (1 - params.target:GetPhysicalArmorReduction() / 100 ) * self.currentlifesteal
            params.attacker:HealEvent(flHeal, self:GetAbility(), params.attacker)
            local lifesteal = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker)
                ParticleManager:SetParticleControlEnt(lifesteal, 0, params.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", params.attacker:GetAbsOrigin(), true)
                ParticleManager:SetParticleControlEnt(lifesteal, 1, params.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", params.attacker:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(lifesteal)
        end
    end
end

function modifier_lifestealer_hunger:GetModifierDamageOutgoing_Percentage()
    return self:GetStackCount()
end

function modifier_lifestealer_hunger:IsHidden()
    return true
end

modifier_lifestealer_hunger_active = class({})

function modifier_lifestealer_hunger_active:OnCreated()
    self.maxdamage = self:GetAbility():GetTalentSpecialValueFor("max_damage_amp")
    self.maxlifesteal = self:GetAbility():GetTalentSpecialValueFor("min_damage_amp")
end

function modifier_lifestealer_hunger_active:OnRefresh()
    self.maxdamage = self:GetAbility():GetTalentSpecialValueFor("max_damage_amp")
    self.maxlifesteal = self:GetAbility():GetTalentSpecialValueFor("max_lifesteal") / 100
end

function modifier_lifestealer_hunger_active:DeclareFunctions()
    funcs = {
                MODIFIER_EVENT_ON_ATTACK_LANDED,
                MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
            }
    return funcs
end

function modifier_lifestealer_hunger_active:OnAttackLanded(params)
    if IsServer() then
        if params.attacker == self:GetParent() then
            local flHeal = params.original_damage * (1 - params.target:GetPhysicalArmorReduction() / 100 ) * self.maxlifesteal
            params.attacker:HealEvent(flHeal, self:GetAbility(), params.attacker)
            local lifesteal = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, params.attacker)
                ParticleManager:SetParticleControlEnt(lifesteal, 0, params.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", params.attacker:GetAbsOrigin(), true)
                ParticleManager:SetParticleControlEnt(lifesteal, 1, params.attacker, PATTACH_POINT_FOLLOW, "attach_hitloc", params.attacker:GetAbsOrigin(), true)
            ParticleManager:ReleaseParticleIndex(lifesteal)
        end
    end
end

function modifier_lifestealer_hunger_active:GetModifierDamageOutgoing_Percentage()
    return self.maxdamage
end

function modifier_lifestealer_hunger_active:IsDebuff()
    return false
end
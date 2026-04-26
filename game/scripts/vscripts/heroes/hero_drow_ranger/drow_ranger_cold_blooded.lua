drow_ranger_cold_blooded = class({})

function drow_ranger_cold_blooded:GetIntrinsicModifierName()
    return "modifier_drow_ranger_cold_blooded"
end

modifier_drow_ranger_cold_blooded = class({})
LinkLuaModifier("modifier_drow_ranger_cold_blooded", "heroes/hero_drow_ranger/drow_ranger_cold_blooded", LUA_MODIFIER_MOTION_NONE)

function modifier_drow_ranger_cold_blooded:IsHidden()
    return true
end

function modifier_drow_ranger_cold_blooded:OnCreated(params)
    self:OnRefresh()
end

function modifier_drow_ranger_cold_blooded:OnRefresh()
    self.attack_chill = self:GetSpecialValueFor("attack_chill")
    self.ability_chill = self:GetSpecialValueFor("ability_chill")
    self.chill_duration = self:GetSpecialValueFor("chill_duration")
    self.frozen_cap = self:GetSpecialValueFor("frozen_cap")
    self.restore_aoe = self:GetSpecialValueFor("restore_aoe")
    self.hp_restore = self:GetSpecialValueFor("hp_restore") / 100
    self.mp_restore = self:GetSpecialValueFor("mp_restore") / 100

    self.cooldown_reduction = self:GetSpecialValueFor("cooldown_reduction") / 100
    self.bonus_agi = self:GetSpecialValueFor("bonus_agi")
    self.buff_duration = self:GetSpecialValueFor("buff_duration")
    self.enemies_frozen = {}

    if IsServer() then
        self.normal_arrow = self:GetParent():GetRangedProjectileName()
    end
    self:StartIntervalThink(0)
end

function modifier_drow_ranger_cold_blooded:DeclareFunctions()
    return
    {
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_SPELL_APPLIED_SUCCESSFULLY,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
end

function modifier_drow_ranger_cold_blooded:OnIntervalThink()
    local caster = self:GetCaster()
    local parent = self:GetParent()

    if IsServer() then
        for _, enemies in ipairs(caster:FindEnemyUnitsInRadius(parent:GetAbsOrigin(), self.restore_aoe)) do
            if enemies:IsFrozenGeneric() and not self.enemies_frozen[enemies:entindex()] then
                self.enemies_frozen[enemies:entindex()] = true
                
                local hpRestore = parent:GetMaxHealth() * self.hp_restore
                local mpRestore = parent:GetMaxMana() * self.mp_restore
                parent:HealEvent(hpRestore, self:GetAbility(), caster)
                parent:RestoreMana(mpRestore)

                if self.cooldown_reduction ~= 0 then
                    for i = 0, parent:GetAbilityCount() - 1 do
                        local ability = parent:GetAbilityByIndex(i)
                        if ability and ability:GetCooldownTimeRemaining() > 0 and ability ~= nil and not ability:IsInnateAbility() then
                            ability:ModifyCooldown(-ability:GetCooldownTimeRemaining() * self.cooldown_reduction)
                        end
                    end
                end
            else
                if not enemies:IsFrozenGeneric() and self.enemies_frozen[enemies:entindex()] then
                    self.enemies_frozen[enemies:entindex()] = false
                end
            end
        end
    end
end

function modifier_drow_ranger_cold_blooded:OnTakeDamage(params)
    local attacker = params.attacker
    local target = params.unit
    local parent = self:GetParent()
    if attacker == parent then
        if target:GetChillCount() < self.frozen_cap then
            target:AddChill(self:GetAbility(), self:GetCaster(), self.chill_duration, self.attack_chill)
        end
    end

    if self.bonus_agi ~= 0 then
       if target:IsFrozenGeneric() and attacker == self:GetParent() or attacker:IsSameTeam(self:GetParent()) then
        attacker:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_drow_ranger_cold_blooded_archery", {duration = self.buff_duration})
        end
    end
end

function modifier_drow_ranger_cold_blooded:OnAttack(params)
    local attacker = params.attacker
    local target = params.target

    if IsServer() then
        if target:HasModifier("modifier_drow_ranger_huntress_mark") and attacker == self:GetParent() then
            attacker:SetRangedProjectileName("particles/units/heroes/hero_drow/drow_frost_arrow.vpcf")
        else
            attacker:SetRangedProjectileName(self.normal_arrow)
        end
    end
end

function modifier_drow_ranger_cold_blooded:OnSpellAppliedSuccessfully(params)
    local caster = self:GetCaster()

	if params.ability:GetCaster() ~= caster then return end
    if not params.target then return end
	if params.target:IsSameTeam( caster ) then return end

    params.target:AddChill(params.ability, caster, self.chill_duration, self.ability_chill)
end

modifier_drow_ranger_cold_blooded_archery = class({})
LinkLuaModifier("modifier_drow_ranger_cold_blooded_archery", "heroes/hero_drow_ranger/drow_ranger_cold_blooded", LUA_MODIFIER_MOTION_NONE)

function modifier_drow_ranger_cold_blooded_archery:OnCreated()
    self:OnRefresh()
end

function modifier_drow_ranger_cold_blooded_archery:OnRefresh()
    self.bonus_agi = self:GetSpecialValueFor("bonus_agi")
    self.bonus_agi_melee = self:GetSpecialValueFor("bonus_agi_melee")
    self:GetParent():HookInModifier("GetModifierAgilityBonusPercentage", self)
end

function modifier_drow_ranger_cold_blooded_archery:OnDestroy()
    self:GetParent():HookOutModifier("GetModifierAgilityBonusPercentage", self)
end

function modifier_drow_ranger_cold_blooded_archery:GetModifierAgilityBonusPercentage()
    if self:GetParent():IsRangedAttacker() then
        return self.bonus_agi
    else
        return self.bonus_agi_melee
    end
end
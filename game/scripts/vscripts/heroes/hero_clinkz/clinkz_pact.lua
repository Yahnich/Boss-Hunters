clinkz_pact = class({})
LinkLuaModifier( "modifier_clinkz_pact", "heroes/hero_clinkz/clinkz_pact.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_clinkz_pact_stun", "heroes/hero_clinkz/clinkz_pact.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_clinkz_pact_wraith", "heroes/hero_clinkz/clinkz_pact.lua" ,LUA_MODIFIER_MOTION_NONE )

function clinkz_pact:IsStealable()
    return true
end

function clinkz_pact:IsHiddenWhenStolen()
    return false
end

function clinkz_pact:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    local caster = self:GetCaster()
    local talent = "special_bonus_unique_clinkz_pact_2"
    if caster:HasTalent( talent ) then cooldown = cooldown + caster:FindTalentValue( talent ) end
    return cooldown
end

function clinkz_pact:OnSpellStart()
	local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    EmitSoundOn("Hero_Clinkz.DeathPact.Cast", caster)
    EmitSoundOn("Hero_Clinkz.DeathPact", target)

    local damage = target:GetHealth() * self:GetTalentSpecialValueFor("damage")/100
    self.hpPercent = damage * self:GetTalentSpecialValueFor("hp_percent")/100
    self.dmgPercent = damage * self:GetTalentSpecialValueFor("damage_percent")/100

    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_clinkz/clinkz_death_pact.vpcf", PATTACH_POINT_FOLLOW, caster)
                ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
                ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
                ParticleManager:SetParticleControlEnt(nfx, 5, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
                ParticleManager:ReleaseParticleIndex(nfx)

    if target:IsRoundBoss() then
        self:DealDamage(caster, target, damage, {damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION}, 0)
    else
        target:ForceKill(false)
    end

    if caster:HasTalent("special_bonus_unique_clinkz_pact_1") then
        CreateModifierThinker(caster, self, "modifier_clinkz_pact_stun", {Duration = 2}, self:GetCursorPosition(), caster:GetTeam(), false)
    end

    caster:AddNewModifier(caster, self, "modifier_clinkz_pact", {Duration = self:GetTalentSpecialValueFor("duration"), hpPercent = self.hpPercent, dmgPercent = self.dmgPercent})
    self:StartDelayedCooldown(self:GetTalentSpecialValueFor("duration"))
end

modifier_clinkz_pact = class({})
function modifier_clinkz_pact:IsDebuff()
    return false
end

function modifier_clinkz_pact:IsPurgable()
    return false
end

function modifier_clinkz_pact:OnCreated(table)
    self.hpPercent = table.hpPercent
    self.dmgPercent = table.hpPercent

    if self:GetCaster():HasTalent("special_bonus_unique_clinkz_pact_2") then
        self.min_health = 1
        self.talent = true
    end

    if IsServer() then 
        self:GetCaster():CalculateStatBonus()
    end
end

function modifier_clinkz_pact:OnRefresh(table)
    self.hpPercent = table.hpPercent
    self.dmgPercent = table.hpPercent

    if self:GetCaster():HasTalent("special_bonus_unique_clinkz_pact_2") then
        self.min_health = 1
        self.talent = true
    end

    if IsServer() then 
        self:GetCaster():CalculateStatBonus()
    end
end

function modifier_clinkz_pact:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_MIN_HEALTH
    }
    return funcs
end

function modifier_clinkz_pact:GetModifierBaseAttack_BonusDamage()
    return self.dmgPercent
end

function modifier_clinkz_pact:GetModifierHealthBonus()
    return self.hpPercent
end

function modifier_clinkz_pact:OnTakeDamage(keys)
    if IsServer() then
        local parent = self:GetParent()
        local attacker = keys.attacker
        local target = keys.unit 
        local damage = keys.damage

        if self.talent and parent == target then
            if damage >= parent:GetHealth() then
                local duration = 4
                parent:AddNewModifier(parent, self:GetAbility(), "modifier_clinkz_pact_wraith", {duration = duration})              
            end
        end
    end
end

function modifier_clinkz_pact:GetMinHealth()
    return self.min_health
end

function modifier_clinkz_pact:GetEffectName()
    return "particles/units/heroes/hero_clinkz/clinkz_death_pact_buff.vpcf"
end

modifier_clinkz_pact_stun = class({})
function modifier_clinkz_pact_stun:OnCreated(table)
    if IsServer() then
        local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_clinkz/clinkz_death_pact_trap.vpcf", PATTACH_POINT, self:GetCaster())
                    ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
                    ParticleManager:SetParticleControl(nfx, 3, self:GetParent():GetAbsOrigin())
        self:AttachEffect(nfx)
    end
end

function modifier_clinkz_pact_stun:OnRemoved()
    if IsServer() then
        local caster = self:GetCaster()
        local point = self:GetParent():GetAbsOrigin()

        local radius = 350
        local duration = 2

        local enemies = caster:FindEnemyUnitsInRadius(point, radius)
        for _,enemy in pairs(enemies) do
            self:GetAbility():Stun(enemy, 2, false)
        end
    end
end

modifier_clinkz_pact_wraith = class({})

function modifier_clinkz_pact_wraith:OnCreated()
    if IsServer() then
        ParticleManager:FireParticle("particles/units/heroes/hero_clinkz/clinkz_windwalk.vpcf", PATTACH_POINT, caster, {})
    end
end

function modifier_clinkz_pact_wraith:IsHidden() return false end
function modifier_clinkz_pact_wraith:IsPurgable() return false end

function modifier_clinkz_pact_wraith:DeclareFunctions()
    local funcs = {   MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
                      MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
                      MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE,
                      MODIFIER_PROPERTY_MODEL_SCALE}
    return funcs
end

function modifier_clinkz_pact_wraith:GetAbsoluteNoDamageMagical()
    return 1
end

function modifier_clinkz_pact_wraith:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_clinkz_pact_wraith:GetAbsoluteNoDamagePure()
    return 1
end

function modifier_clinkz_pact_wraith:GetDisableHealing()
    return 1
end

function modifier_clinkz_pact_wraith:GetModifierModelScale()
    return 40
end

function modifier_clinkz_pact_wraith:GetEffectName()
    return "particles/units/heroes/hero_huskar/huskar_burning_spear_debuff.vpcf"
end

function modifier_clinkz_pact_wraith:GetStatusEffectName()
    return "particles/status_fx/status_effect_burn.vpcf"
end

function modifier_clinkz_pact_wraith:StatusEffectPriority()
    return 10
end

function modifier_clinkz_pact_wraith:IsDebuff()
    return false
end
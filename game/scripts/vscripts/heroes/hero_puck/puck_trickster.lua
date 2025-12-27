puck_trickster = class({})

function puck_trickster:GetIntrinsicModifierName()
    return "modifier_puck_trickster"
end

modifier_puck_trickster = class({})
LinkLuaModifier("modifier_puck_trickster", "heroes/hero_puck/puck_trickster", LUA_MODIFIER_MOTION_NONE)

function modifier_puck_trickster:IsHidden()
    return true
end

function modifier_puck_trickster:OnCreated()
    self:OnRefresh()
end

function modifier_puck_trickster:OnRefresh()
    self.base_restore = self:GetSpecialValueFor("base_restore")
    self.percent_restore = self:GetSpecialValueFor("percent_restore") / 100

    self.bonus_magic_damage = self:GetSpecialValueFor("bonus_magic_damage")
    self.bonus_debuff_duration = self:GetSpecialValueFor("bonus_debuff_duration")
    self.evasion_trigger = self:GetSpecialValueFor("evasion_trigger")
    self.evasion_cooldown = self:GetSpecialValueFor("evasion_cooldown")
end

function modifier_puck_trickster:DeclareFunctions()
    return
    {
        MODIFIER_EVENT_ON_PROJECTILE_DODGE,
        MODIFIER_EVENT_ON_ATTACK_FAIL,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_MAX_DEBUFF_DURATION,
    }
end

function modifier_puck_trickster:OnProjectileDodge(params)
    if not IsServer() then return end
    if params.target == self:GetParent() then
        local healthRestore = self:GetParent():GetMaxHealth() * self.percent_restore
        local manaRestore = self:GetParent():GetMaxMana() * self.percent_restore
        self:GetParent():HealEvent(self.base_restore + healthRestore)
        self:GetParent():RestoreMana(self.base_restore + manaRestore)
    end
end

function modifier_puck_trickster:GetModifierProcAttack_BonusDamage_Magical()
    return self.bonus_magic_damage
end

function modifier_puck_trickster:GetModifierMaxDebuffDuration()
    return self.bonus_debuff_duration
end

--there might be an evasion event
function modifier_puck_trickster:OnAttackFail(params)
    if not IsServer() then return end
    if self.evasion_trigger == 0 then return end
    if not params.target == self:GetParent() then return end

    if not self:GetParent():HasModifier("modifier_puck_trickster_crystalhide_cooldown") then
        local healthRestore = self:GetParent():GetMaxHealth() * self.percent_restore
        local manaRestore = self:GetParent():GetMaxMana() * self.percent_restore
        self:GetParent():HealEvent(self.base_restore + healthRestore)
        self:GetParent():RestoreMana(self.base_restore + manaRestore)
        self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_puck_trickster_crystalhide_cooldown", {duration = self.evasion_cooldown})
    end
end


modifier_puck_trickster_crystalhide_cooldown = class({})
LinkLuaModifier("modifier_puck_trickster_crystalhide_cooldown", "heroes/hero_puck/puck_trickster", LUA_MODIFIER_MOTION_NONE)

function modifier_puck_trickster_crystalhide_cooldown:IsDebuff()
    return true
end

function modifier_puck_trickster_crystalhide_cooldown:IsPurgable()
    return false
end
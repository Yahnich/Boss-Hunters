kotl_spirit = class({})
LinkLuaModifier( "modifier_kotl_spirit", "heroes/hero_kotl/kotl_spirit.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kotl_spirit_blind", "heroes/hero_kotl/kotl_spirit.lua" ,LUA_MODIFIER_MOTION_NONE )

function kotl_spirit:IsStealable()
    return true
end

function kotl_spirit:IsHiddenWhenStolen()
    return false
end

function kotl_spirit:OnInventoryContentsChanged()
    if self:GetCaster():HasScepter() then
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_kotl_spirit", {})
        self:SetActivated(false)
    else
        self:GetCaster():RemoveModifierByName("modifier_kotl_spirit")
        self:SetActivated(true)
    end
end

function kotl_spirit:OnSpellStart()
    local caster = self:GetCaster()
    EmitSoundOn("Hero_KeeperOfTheLight.SpiritForm", caster)
    caster:AddNewModifier(caster, self, "modifier_kotl_spirit", {Duration = self:GetSpecialValueFor("duration")})
end

function kotl_spirit:OnUpgrade()
    local caster = self:GetCaster()
    caster:FindAbilityByName("kotl_recall"):SetLevel(self:GetLevel())
    caster:FindAbilityByName("kotl_blind"):SetLevel(self:GetLevel())

    if not caster:HasModifier("modifier_kotl_spirit") then
        caster:FindAbilityByName("kotl_recall"):SetActivated(false)
        caster:FindAbilityByName("kotl_blind"):SetActivated(false)
    end
end

modifier_kotl_spirit = class({})
function modifier_kotl_spirit:OnCreated(table)
    self.int = self:GetCaster():GetIntellect()*self:GetSpecialValueFor("bonus_int")/100
	self.cdr = self:GetCaster():FindTalentValue("special_bonus_unique_kotl_spirit_2")

    if IsServer() then
        local caster = self:GetCaster()
        caster:FindAbilityByName("kotl_recall"):SetActivated(true)
        caster:FindAbilityByName("kotl_blind"):SetActivated(true)
		if caster:HasScepter() then self:StartIntervalThink(0.03) end
    end
end

function modifier_kotl_spirit:OnRefresh(table)
    self.int = self:GetCaster():GetIntellect()*self:GetSpecialValueFor("bonus_int")/100
	self.cdr = self:GetCaster():FindTalentValue("special_bonus_unique_kotl_spirit_2")

    if IsServer() then
        local caster = self:GetCaster()
        caster:FindAbilityByName("kotl_recall"):SetActivated(true)
        caster:FindAbilityByName("kotl_blind"):SetActivated(true)
		if caster:HasScepter() then self:StartIntervalThink(0.03) end
    end
end


function modifier_kotl_spirit:OnIntervalThink()
	local caster = self:GetCaster()
	if caster:HasScepter() and GameRules:IsDaytime() then
		self:GetAbility():CreateVisibilityNode(caster:GetAbsOrigin(), caster:GetDayTimeVisionRange(), 0.04)
	elseif not caster:HasScepter() then
		self:StartIntervalThink(-1)
	end
end

function modifier_kotl_spirit:OnRemoved()
    if IsServer() then
        local caster = self:GetCaster()
        caster:FindAbilityByName("kotl_recall"):SetActivated(false)
        caster:FindAbilityByName("kotl_blind"):SetActivated(false)
    end
end

function modifier_kotl_spirit:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING
    }
    return funcs
end

function modifier_kotl_spirit:GetModifierPercentageCooldownStacking()
    return self.cdr
end

function modifier_kotl_spirit:GetModifierBonusStats_Intellect()
    return self.int
end

function modifier_kotl_spirit:GetEffectName()
    return "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_spirit_form_ambient.vpcf"
end

function modifier_kotl_spirit:GetStatusEffectName()
    return "particles/status_fx/status_effect_keeper_spirit_form.vpcf"
end

function modifier_kotl_spirit:StatusEffectPriority()
    return 10
end

function modifier_kotl_spirit:IsAura()
    return self:GetCaster():HasTalent("special_bonus_unique_kotl_spirit_1")
end

function modifier_kotl_spirit:GetAuraDuration()
    return 0.5
end

function modifier_kotl_spirit:GetAuraRadius()
    return self:GetCaster():FindTalentValue("special_bonus_unique_kotl_spirit_1", "value")
end

function modifier_kotl_spirit:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_kotl_spirit:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_kotl_spirit:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_kotl_spirit:GetModifierAura()
    return "modifier_kotl_spirit_blind"
end

function modifier_kotl_spirit:IsAuraActiveOnDeath()
    return false
end

modifier_kotl_spirit_blind = class({})
function modifier_kotl_spirit_blind:CheckState()
    local state = { [MODIFIER_STATE_BLIND] = true}
    return state
end

function modifier_kotl_spirit_blind:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MISS_PERCENTAGE
    }
    return funcs
end

function modifier_kotl_spirit_blind:GetModifierMiss_Percentage()
    return self:GetCaster():FindTalentValue("special_bonus_unique_kotl_spirit_1", "chance")
end

function modifier_kotl_spirit_blind:GetEffectName()
    return "particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_blinding_light_debuff.vpcf"
end

function modifier_kotl_spirit_blind:IsPurgable()
    return true
end

function modifier_kotl_spirit_blind:IsPurgeException()
    return true
end

function modifier_kotl_spirit_blind:IsDebuff()
    return true
end
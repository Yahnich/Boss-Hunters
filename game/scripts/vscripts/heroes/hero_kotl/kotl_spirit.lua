kotl_spirit = class({})
LinkLuaModifier( "modifier_kotl_spirit", "heroes/hero_kotl/kotl_spirit.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_kotl_remove_aghs_spirit", "heroes/hero_kotl/kotl_spirit.lua" ,LUA_MODIFIER_MOTION_NONE )

function kotl_spirit:IsStealable()
    return false
end

function kotl_spirit:IsHiddenWhenStolen()
    return false
end

function kotl_spirit:CastFilterResult()
    if self:GetCaster():PassivesDisabled() then
        return UF_FAIL_CUSTOM
    end
    return UF_SUCCESS
end

function kotl_spirit:GetCustomCastError()
    if self:GetCaster():PassivesDisabled() then
        return "Innate is currently broken."
    end
end

function kotl_spirit:OnToggle()
    local caster = self:GetCaster()

    if caster:HasModifier("modifier_kotl_spirit") then
        caster:RemoveModifierByName("modifier_kotl_spirit")
    else
        EmitSoundOn("Hero_KeeperOfTheLight.SpiritForm", caster)
        caster:AddNewModifier(caster, self, "modifier_kotl_spirit", {})
    end
end

function kotl_spirit:OnInventoryContentsChanged()
    local caster = self:GetCaster()

    if caster:HasScepter() then
        caster:RemoveModifierByName("modifier_keeper_of_the_light_spirit_form") 
    end
end

modifier_kotl_spirit = class({})
function modifier_kotl_spirit:OnCreated(table)
    --if not self:GetCaster():HasModifier("modifier_kotl_spirit") then
        self.bonus_int = self:GetSpecialValueFor("bonus_int")
    	self.mana_cost = self:GetSpecialValueFor("mana_cost")
    --end

    self.radius = self:GetSpecialValueFor("radius")

    if IsServer() then
        EmitSoundOn("Hero_KeeperOfTheLight.SpiritForm", self:GetCaster())

        self.mana_drain = self:GetCaster():GetMaxMana() * self:GetSpecialValueFor("mana_drain")/100 * 0.1

        self:StartIntervalThink(0.1)
    end
end

function modifier_kotl_spirit:OnRemoved()
    if IsServer() then
        StopSoundOn("Hero_KeeperOfTheLight.SpiritForm", self:GetCaster())
    end
end

function modifier_kotl_spirit:OnIntervalThink()
	local caster = self:GetCaster()
	
    caster:SetMana(caster:GetMana() - self.mana_drain)
end

function modifier_kotl_spirit:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL
    }
    return funcs
end

function modifier_kotl_spirit:GetModifierPercentageManacost()
    return self.mana_cost
end

function modifier_kotl_spirit:GetModifierIntellectBonusPercentage()
    return self.bonus_int
end

function modifier_kotl_spirit:GetModifierInvisibilityLevel()
    return 0
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
    return true
end

function modifier_kotl_spirit:GetAuraDuration()
    return 0.5
end

function modifier_kotl_spirit:GetAuraRadius()
    return self.radius
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
    return "modifier_blind_generic"
end

function modifier_kotl_spirit:IsAuraActiveOnDeath()
    return false
end

modifier_kotl_remove_aghs_spirit = class({})
function modifier_kotl_remove_aghs_spirit:OnCreated(table)
    if IsServer() then
        self:StartIntervalThink(0.1)
    end
end

function modifier_kotl_remove_aghs_spirit:OnIntervalThink()
    self:GetCaster():RemoveModifierByName("modifier_keeper_of_the_light_spirit_form")
end

function modifier_kotl_remove_aghs_spirit:IsHidden()
    return true
end

function modifier_kotl_remove_aghs_spirit:IsPurgable()
    return false
end

function modifier_kotl_remove_aghs_spirit:IsPurgeException()
    return false
end
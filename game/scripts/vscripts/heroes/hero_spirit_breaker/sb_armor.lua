sb_armor = class({})
LinkLuaModifier( "modifier_sb_armor_handle", "heroes/hero_spirit_breaker/sb_armor.lua" ,LUA_MODIFIER_MOTION_NONE )

function sb_armor:IsStealable()
    return true
end

function sb_armor:IsHiddenWhenStolen()
    return false
end

function sb_armor:GetIntrinsicModifierName()
	return "modifier_sb_armor_handle"
end

modifier_sb_armor_handle = class({})
function modifier_sb_armor_handle:IsHidden()
    return true
end

function modifier_sb_armor_handle:OnCreated(table)
    self:StartIntervalThink(0.1)
end

function modifier_sb_armor_handle:OnIntervalThink()
    local caster = self:GetCaster()
    self.armor = (caster:GetIdealSpeed() - 100) * self:GetSpecialValueFor("ms_to_armor")/100
end

function modifier_sb_armor_handle:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
    }
    return funcs
end

function modifier_sb_armor_handle:GetModifierPhysicalArmorBonus()
    return self.armor
end
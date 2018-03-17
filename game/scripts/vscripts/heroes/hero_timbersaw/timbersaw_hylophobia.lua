timbersaw_hylophobia = class({})
LinkLuaModifier( "modifier_timbersaw_hylophobia", "heroes/hero_timbersaw/timbersaw_hylophobia.lua" ,LUA_MODIFIER_MOTION_NONE )

modifier_timbersaw_hylophobia = class({})
function modifier_timbersaw_hylophobia:DeclareFunctions()
    funcs = {   MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE }
    return funcs
end

function modifier_timbersaw_hylophobia:GetModifierSpellAmplify_Percentage()
    return self:GetTalentSpecialValueFor("bonus_spell_amp") * self:GetStackCount()
end

function modifier_timbersaw_hylophobia:IsPurgable()
    return false
end
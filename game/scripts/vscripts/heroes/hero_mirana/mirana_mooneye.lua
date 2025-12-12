mirana_mooneye = class({})

function mirana_mooneye:GetIntrinsicModifierName()
    return "modifier_mirana_mooneye"
end

function mirana_mooneye:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

modifier_mirana_mooneye = class({})
LinkLuaModifier( "modifier_mirana_mooneye", "heroes/hero_mirana/mirana_mooneye.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_mirana_mooneye:OnCreated()
	self:OnRefresh()
end

function modifier_mirana_mooneye:OnRefresh()
	self.spell_amp = self:GetSpecialValueFor("agi_spellamp")
end

function modifier_mirana_mooneye:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE 
    }
    return funcs
end

function modifier_mirana_mooneye:GetModifierSpellAmplify_Percentage(params)
    return self.spell_amp * self:GetParent():GetAgility()
end

function modifier_mirana_mooneye:IsHidden()
    return true
end

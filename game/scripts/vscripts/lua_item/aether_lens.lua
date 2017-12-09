item_redium_lens = class({})

function item_redium_lens:GetIntrinsicModifierName() 
	return "modifier_item_aether_derivative"
end

item_sunium_lens = class(item_redium_lens)
item_omni_lens = class(item_redium_lens)
item_asura_lens = class(item_redium_lens)

LinkLuaModifier("modifier_item_aether_derivative", "lua_item/aether_lens", 0)
modifier_item_aether_derivative = class({})
function modifier_item_aether_derivative:GetAttributes() 
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_aether_derivative:IsHidden()
    return true
end

function modifier_item_aether_derivative:OnCreated()
	self.amp = self:GetSpecialValueFor("spell_amp")
	self.range = self:GetSpecialValueFor("cast_range_bonus")
end

function modifier_item_aether_derivative:DeclareFunctions() --we want to use these functions in this item
    local funcs = {
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE	,
        MODIFIER_PROPERTY_CAST_RANGE_BONUS,
    }

    return funcs
end

function modifier_item_aether_derivative:GetModifierSpellAmplify_Percentage()
    return self.amp
end

function modifier_item_aether_derivative:GetModifierCastRangeBonus()
    return self.range
end


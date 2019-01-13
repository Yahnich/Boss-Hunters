wisp_spirit_inout = class({})
LinkLuaModifier("modifier_wisp_spirit_inout", "heroes/hero_wisp/wisp_spirit_inout", LUA_MODIFIER_MOTION_NONE)

function wisp_spirit_inout:IsStealable()
    return false
end

function wisp_spirit_inout:IsHiddenWhenStolen()
    return false
end

function wisp_spirit_inout:GetAbilityTextureName()
    if self:GetCaster():HasModifier("modifier_wisp_spirit_inout") then
    	return "wisp_spirits_out"
    end
    return "wisp_spirits_in"
end

function wisp_spirit_inout:OnToggle()
	if self:GetCaster():HasModifier("modifier_wisp_spirit_inout") then
		self:GetCaster():RemoveModifierByName("modifier_wisp_spirit_inout")
	else
		self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_wisp_spirit_inout", {})
	end
end

modifier_wisp_spirit_inout = class({})
function modifier_wisp_spirit_inout:IsHidden()
	return true
end
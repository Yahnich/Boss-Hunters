item_ifrit_other_1 = class({})

function item_ifrit_other_1:GetIntrinsicModifierName()
	return "modifier_item_ifrit_other"
end

item_ifrit_other_2 = class(item_ifrit_other_1)
item_ifrit_other_3 = class(item_ifrit_other_1)
item_ifrit_other_4 = class(item_ifrit_other_1)
item_ifrit_other_5 = class(item_ifrit_other_1)

modifier_item_ifrit_other = class({})
LinkLuaModifier("modifier_item_ifrit_other", "items/ifrit/item_ifrit_other.lua", 0)

function modifier_item_ifrit_other:OnCreated()
	self.cdr = self:GetSpecialValueFor("cdr")
	self.amp = self:GetSpecialValueFor("spell_amp")
	-- if IsServer() then
		-- self:GetCaster():SetEquippedArmor( self:GetAbility():GetAttachmentName() )
	-- end
end

function modifier_item_ifrit_other:OnRefresh()
	self.cdr = self:GetSpecialValueFor("cdr")
	self.amp = self:GetSpecialValueFor("spell_amp")
end

function modifier_item_ifrit_other:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING}
end

function modifier_item_ifrit_other:GetModifierPercentageCooldownStacking()
	return self.cdr
end

function modifier_item_ifrit_other:GetModifierSpellAmplify_Percentage(params)
	return self.amp
end

function modifier_item_ifrit_other:IsHidden()
	return true
end
item_justicar_other_1 = class({})

function item_justicar_other_1:GetIntrinsicModifierName()
	return "modifier_item_justicar_other"
end

item_justicar_other_2 = class(item_justicar_other_1)
item_justicar_other_3 = class(item_justicar_other_1)
item_justicar_other_4 = class(item_justicar_other_1)
item_justicar_other_5 = class(item_justicar_other_1)

modifier_item_justicar_other = class({})
LinkLuaModifier("modifier_item_justicar_other", "items/justicar/item_justicar_other.lua", 0)

function modifier_item_justicar_other:OnCreated()
	self.cdr = self:GetSpecialValueFor("cdr")
	self.amp = self:GetSpecialValueFor("spell_amp")
	-- if IsServer() then
		-- self:GetCaster():SetEquippedArmor( self:GetAbility():GetAttachmentName() )
	-- end
end

function modifier_item_justicar_other:OnRefresh()
	self.cdr = self:GetSpecialValueFor("cdr")
	self.amp = self:GetSpecialValueFor("spell_amp")
end

function modifier_item_justicar_other:DeclareFunctions()
	return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end

function modifier_item_justicar_other:GetModifierPercentageCooldownStacking()
	return self.cdr
end

function modifier_item_justicar_other:GetModifierSpellAmplify_Percentage()
	return self.amp
end

function modifier_item_justicar_other:IsHidden()
	return true
end
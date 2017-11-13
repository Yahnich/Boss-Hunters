item_shinigami_other_1 = class({})

function item_shinigami_other_1:GetIntrinsicModifierName()
	return "modifier_item_shinigami_other"
end

item_shinigami_other_2 = class(item_shinigami_other_1)
item_shinigami_other_3 = class(item_shinigami_other_1)
item_shinigami_other_4 = class(item_shinigami_other_1)
item_shinigami_other_5 = class(item_shinigami_other_1)

modifier_item_shinigami_other = class({})
LinkLuaModifier("modifier_item_shinigami_other", "items/shinigami/item_shinigami_other.lua", 0)

function modifier_item_shinigami_other:OnCreated()
	self.evasion = self:GetSpecialValueFor("evasion")
	-- if IsServer() then
		-- self:GetCaster():SetEquippedArmor( self:GetAbility():GetAttachmentName() )
	-- end
end

function modifier_item_shinigami_other:OnRefresh()
	self.evasion = self:GetSpecialValueFor("evasion")
end

function modifier_item_shinigami_other:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT}
end

function modifier_item_shinigami_other:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_item_shinigami_other:IsHidden()
	return true
end
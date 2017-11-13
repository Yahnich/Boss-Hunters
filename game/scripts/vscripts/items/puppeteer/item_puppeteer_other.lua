item_puppeteer_other_1 = class({})

function item_puppeteer_other_1:GetIntrinsicModifierName()
	return "modifier_item_puppeteer_other"
end

item_puppeteer_other_2 = class(item_puppeteer_other_1)
item_puppeteer_other_3 = class(item_puppeteer_other_1)
item_puppeteer_other_4 = class(item_puppeteer_other_1)
item_puppeteer_other_5 = class(item_puppeteer_other_1)

modifier_item_puppeteer_other = class({})
LinkLuaModifier("modifier_item_puppeteer_other", "items/puppeteer/item_puppeteer_other.lua", 0)

function modifier_item_puppeteer_other:OnCreated()
	self.cdr = self:GetSpecialValueFor("cdr")
	self.amp = self:GetSpecialValueFor("spell_amp")
	-- if IsServer() then
		-- self:GetCaster():SetEquippedArmor( self:GetAbility():GetAttachmentName() )
	-- end
end

function modifier_item_puppeteer_other:OnRefresh()
	self.cdr = self:GetSpecialValueFor("cdr")
	self.amp = self:GetSpecialValueFor("spell_amp")
end

function modifier_item_puppeteer_other:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE, MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE_STACKING}
end

function modifier_item_puppeteer_other:GetModifierPercentageCooldownStacking()
	return self.cdr
end

function modifier_item_puppeteer_other:GetModifierSpellAmplify_Percentage(params)
	return self.amp
end

function modifier_item_puppeteer_other:IsHidden()
	return true
end
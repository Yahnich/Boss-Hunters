event_buff_devil_deal = class(relicBaseClass)

function event_buff_devil_deal:OnCreated()
	self:GetParent():HookInModifier("GetModifierExtraHealthBonusPercentage", self)
end

function event_buff_devil_deal:OnDestroy()
	self:GetParent():HookOutModifier("GetModifierExtraHealthBonusPercentage", self)
end

function event_buff_devil_deal:GetModifierExtraHealthBonusPercentage()
	return -30
end

function event_buff_devil_deal:IsDebuff( )
    return true
end
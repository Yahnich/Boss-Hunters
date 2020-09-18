event_buff_crossroads = class(relicBaseClass)

function event_buff_crossroads:OnCreated()
	self:GetParent():HookInModifier("GetModifierExtraHealthBonusPercentage", self)
end

function event_buff_crossroads:OnDestroy()
	self:GetParent():HookOutModifier("GetModifierExtraHealthBonusPercentage", self)
end

function event_buff_crossroads:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_PERCENTAGE}
end

function event_buff_crossroads:GetModifierExtraHealthBonusPercentage()
	return -20
end

function event_buff_crossroads:IsDebuff( )
    return true
end
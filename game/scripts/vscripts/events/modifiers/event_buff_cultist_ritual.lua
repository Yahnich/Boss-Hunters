event_buff_cultist_ritual = class(relicBaseClass)

function event_buff_cultist_ritual:OnCreated()
	self:SetStackCount(1)
end

function event_buff_cultist_ritual:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DISABLE_HEALING
    }

    return funcs
end

function event_buff_cultist_ritual:GetDisableHealing()
    return 1
end

function event_buff_cultist_ritual:GetTexture()
    return "custom/healing_disabled"
end

function event_buff_cultist_ritual:IsDebuff()
	return true
end

function event_buff_cultist_ritual:IsCurse()
	return true
end
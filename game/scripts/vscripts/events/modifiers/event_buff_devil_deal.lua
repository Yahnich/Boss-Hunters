event_buff_devil_deal = class(relicBaseClass)

function event_buff_devil_deal:OnCreated()
	if IsServer() then
		self:SetStackCount( self:GetParent():GetMaxHealth() * 0.3 )
		self:GetParent():CalculateStatBonus()
		self:StartIntervalThink(0.15)
	end
end

function event_buff_devil_deal:OnIntervalThink()
	if IsServer() then
		self:SetStackCount( 0 )
		self:GetParent():CalculateStatBonus()

		self:SetStackCount( self:GetParent():GetMaxHealth() * 0.3 )
		self:GetParent():CalculateStatBonus()
	end
end

function event_buff_devil_deal:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS}
end

function event_buff_devil_deal:GetModifierExtraHealthBonus()
	return self:GetStackCount() * (-1)
end

function event_buff_devil_deal:IsDebuff( )
    return true
end
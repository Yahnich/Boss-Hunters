event_buff_crossroads = class(relicBaseClass)

function event_buff_crossroads:OnCreated()
	if IsServer() then
		self:SetStackCount( self:GetParent():GetMaxHealth() * 0.2 )
		self:GetParent():CalculateStatBonus()
		self:StartIntervalThink(0.15)
	end
end

function event_buff_crossroads:OnIntervalThink()
	if IsServer() then
		self:SetStackCount( 0 )
		self:GetParent():CalculateStatBonus()

		self:SetStackCount( self:GetParent():GetMaxHealth() * 0.2 )
		self:GetParent():CalculateStatBonus()
	end
end

function event_buff_crossroads:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS}
end

function event_buff_crossroads:GetModifierExtraHealthBonus()
	return self:GetStackCount() * (-1)
end

function event_buff_crossroads:IsDebuff( )
    return true
end
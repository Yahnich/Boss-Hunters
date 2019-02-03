relic_icon_of_lust = class(relicBaseClass)

function relic_icon_of_lust:OnCreated()
	if IsServer() then
		self:SetStackCount( self:GetParent():GetMaxHealth() * 0.2 )
		self:GetParent():CalculateStatBonus()
		self:StartIntervalThink(0.15)
	end
end

function relic_icon_of_lust:OnIntervalThink()
	if IsServer() then
		self:SetStackCount( 0 )
		self:GetParent():CalculateStatBonus()

		self:SetStackCount( self:GetParent():GetMaxHealth() * 0.2 )
		self:GetParent():CalculateStatBonus()
	end
end

function relic_icon_of_lust:DeclareFunctions()
	return {MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE, MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS}
end

function relic_icon_of_lust:GetModifierIncomingDamage_Percentage(params)
	if self:RollPRNG( 15 ) then
		self:GetParent():HealEvent( params.damage, nil, nil )
	end
end

function relic_icon_of_lust:GetModifierExtraHealthBonus()
	if not self:GetParent():HasModifier("relic_ritual_candle") then return self:GetStackCount() * (-1) end
end
event_buff_stick = class(relicBaseClass)

function event_buff_stick:OnCreated()
	if IsServer() then
		self:SetStackCount( self:GetParent():GetMaxHealth() * 0.3 )
		self:GetParent():CalculateStatBonus()
		self:StartIntervalThink(0.15)
	end
end

function event_buff_stick:OnIntervalThink()
	if IsServer() then
		self:SetStackCount( 0 )
		self:GetParent():CalculateStatBonus()

		self:SetStackCount( self:GetParent():GetMaxHealth() * 0.3 )
		self:GetParent():CalculateStatBonus()
	end
end

function event_buff_stick:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			
			MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,}
end

function event_buff_stick:GetModifierPreAttack_BonusDamage()
	return 20
end

function event_buff_stick:GetModifierAttackSpeedBonus()
	return 20
end

function event_buff_stick:GetModifierMoveSpeedBonus_Constant()
	return 20
end
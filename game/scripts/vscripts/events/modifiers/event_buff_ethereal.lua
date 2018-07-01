event_buff_ethereal = class(relicBaseClass)

function event_buff_ethereal:OnCreated()
	if IsServer() then
		self:SetStackCount( self:GetParent():GetMaxHealth() * 0.3 )
		self:GetParent():CalculateStatBonus()
		self:StartIntervalThink(0.15)
	end
end

function event_buff_ethereal:OnIntervalThink()
	if IsServer() then
		self:SetStackCount( 0 )
		self:GetParent():CalculateStatBonus()

		self:SetStackCount( self:GetParent():GetMaxHealth() * 0.3 )
		self:GetParent():CalculateStatBonus()
	end
end

function event_buff_ethereal:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
			MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL}
end

function event_buff_ethereal:GetModifierMagicalResistanceBonus()
	return -100
end

function event_buff_ethereal:GetAbsoluteNoDamagePhysical()
	return 1
end

function event_buff_ethereal:CheckState()
	return {[MODIFIER_STATE_DISARMED] = true}
end

function event_buff_ethereal:GetEffectName()
	return "particles/items_fx/ghost.vpcf"
end

function event_buff_ethereal:GetStatusEffectName()
	return "particles/status_fx/status_effect_ghost.vpcf"
end

function event_buff_ethereal:StatusEffectPriority()
	return 20
end
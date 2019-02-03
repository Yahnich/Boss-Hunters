relic_rapid_totem = class(relicBaseClass)

function relic_rapid_totem:OnCreated()
	self:SetStackCount(0)
end

function relic_rapid_totem:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function relic_rapid_totem:GetCooldownReduction()
	return 60
end

function relic_rapid_totem:GetModifierTotalDamageOutgoing_Percentage(params)
	if params.inflictor then
		return -40
	end
end

function relic_rapid_totem:GetModifierStatusAmplify_Percentage(params)
	return -50
end
relic_unique_rapid_totem = class({})

function relic_unique_rapid_totem:OnCreated()
	self:SetStackCount(0)
end

function relic_unique_rapid_totem:DeclareFunctions()
	return {MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE, MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function relic_unique_rapid_totem:GetModifierPercentageCooldown()
	return 50
end

function relic_unique_rapid_totem:GetModifierTotalDamageOutgoing_Percentage(params)
	if params.inflictor then
		return -40
	end
end

function relic_unique_rapid_totem:GetModifierStatusAmplify_Percentage(params)
	return -50
end

function relic_unique_rapid_totem:IsHidden()
	return true
end

function relic_unique_rapid_totem:IsPurgable()
	return false
end

function relic_unique_rapid_totem:RemoveOnDeath()
	return false
end

function relic_unique_rapid_totem:IsPermanent()
	return true
end

function relic_unique_rapid_totem:AllowIllusionDuplicate()
	return true
end



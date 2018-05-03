relic_cursed_red_key = class({})

function relic_cursed_red_key:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function relic_cursed_red_key:GetModifierTotalDamageOutgoing_Percentage(params)
	if self:GetStackCount() == 1 then
		return -25
	end
end

function relic_cursed_red_key:IsHidden()
	return self:GetStackCount() ~= 1
end

function relic_cursed_red_key:IsPurgable()
	return false
end

function relic_cursed_red_key:RemoveOnDeath()
	return false
end

function relic_cursed_red_key:IsPermanent()
	return true
end

function relic_cursed_red_key:AllowIllusionDuplicate()
	return true
end

function relic_cursed_red_key:IsDebuff()
	return true
end

function relic_cursed_red_key:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
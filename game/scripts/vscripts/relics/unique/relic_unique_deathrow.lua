relic_unique_deathrow = class({})

function relic_unique_deathrow:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, MODIFIER_EVENT_ON_DEATH}
end

function relic_unique_deathrow:GetModifierPreAttack_CriticalStrike()
	if RollPercentage(20) then return 200 + self:GetStackCount() * 10 end
end

function relic_unique_deathrow:OnDeath(params)
	if params.attacker == self:GetParent() and params.unit.Holdout_IsCore then
		self:IncrementStackCount()
	end
end

function relic_unique_deathrow:IsHidden()
	return false
end

function relic_unique_deathrow:IsPurgable()
	return false
end

function relic_unique_deathrow:RemoveOnDeath()
	return false
end

function relic_unique_deathrow:IsPermanent()
	return true
end

function relic_unique_deathrow:AllowIllusionDuplicate()
	return true
end

function relic_unique_deathrow:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
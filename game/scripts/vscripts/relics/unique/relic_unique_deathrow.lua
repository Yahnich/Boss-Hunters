relic_unique_deathrow = class(relicBaseClass)

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
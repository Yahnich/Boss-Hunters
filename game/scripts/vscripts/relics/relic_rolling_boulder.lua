relic_rolling_boulder = class(relicBaseClass)

function relic_rolling_boulder:OnCreated()
	self:SetStackCount(0)
end

function relic_rolling_boulder:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK, MODIFIER_PROPERTY_STATS_AGILITY_BONUS}
end

function relic_rolling_boulder:OnAttack(params)
	if params.attacker == self:GetParent() then
		self:AddIndependentStack(15, nil)
	end
end

function relic_rolling_boulder:GetModifierBonusStats_Agility()
	return self:GetStackCount()
end

function relic_rolling_boulder:IsHidden()
	return false
end
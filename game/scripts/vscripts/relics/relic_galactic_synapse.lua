relic_galactic_synapse = class(relicBaseClass)

function relic_galactic_synapse:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS }
end

function relic_galactic_synapse:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() and params.unit:HasAbility( params.ability:GetName() ) and not params.ability:IsOrbAbility() and params.ability:GetCooldownTimeRemaining() > 0 then
		self:AddIndependentStack(30, nil)
		self:GetParent():CalculateStatBonus()
	end
end

function relic_galactic_synapse:GetModifierBonusStats_Intellect()
	return self:GetStackCount() * 10
end

function relic_galactic_synapse:IsHidden()
	return false
end
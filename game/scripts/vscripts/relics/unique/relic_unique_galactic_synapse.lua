relic_unique_galactic_synapse = class({})

function relic_unique_galactic_synapse:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS }
end

function relic_unique_galactic_synapse:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() and params.unit:HasAbility( params.ability:GetName() ) and not params.ability:IsOrbAbility() and params.ability:GetCooldown(-1) > 0 then
		self:AddIndependentStack(30, nil, false)
		self:GetParent():CalculateStatBonus()
	end
end

function relic_unique_galactic_synapse:GetModifierBonusStats_Intellect()
	return self:GetStackCount() * 10
end


function relic_unique_galactic_synapse:IsHidden()
	return false
end

function relic_unique_galactic_synapse:IsPurgable()
	return false
end

function relic_unique_galactic_synapse:RemoveOnDeath()
	return false
end

function relic_unique_galactic_synapse:IsPermanent()
	return true
end

function relic_unique_galactic_synapse:AllowIllusionDuplicate()
	return true
end

function relic_unique_galactic_synapse:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
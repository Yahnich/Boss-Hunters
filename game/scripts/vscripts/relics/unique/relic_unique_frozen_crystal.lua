relic_unique_frozen_crystal = class({})

function relic_unique_frozen_crystal:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function relic_unique_frozen_crystal:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() and params.unit:HasAbility( params.ability:GetName() ) and not params.ability:IsOrbAbility() then
		local parent = self:GetParent()
		local position = parent:GetAbsOrigin()
		
		local duration = 15
		local radius = 425
		
		for _, enemy in ipairs( parent:FindEnemyUnitsInRadius(position, radius) ) do
			enemy:AddChill(nil, parent, duration, 15)
		end
	end
end

function relic_unique_frozen_crystal:IsHidden()
	return true
end

function relic_unique_frozen_crystal:IsPurgable()
	return false
end

function relic_unique_frozen_crystal:RemoveOnDeath()
	return false
end

function relic_unique_frozen_crystal:IsPermanent()
	return true
end

function relic_unique_frozen_crystal:AllowIllusionDuplicate()
	return true
end
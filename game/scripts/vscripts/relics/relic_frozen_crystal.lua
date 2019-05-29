relic_frozen_crystal = class(relicBaseClass)

function relic_frozen_crystal:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function relic_frozen_crystal:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() and params.unit:HasAbility( params.ability:GetName() ) and not params.ability:IsOrbAbility() and params.ability:GetCooldown(-1) > 0 then
		local parent = self:GetParent()
		local position = parent:GetAbsOrigin()
		
		local duration = 15
		local radius = 425
		
		for _, enemy in ipairs( parent:FindEnemyUnitsInRadius(position, radius) ) do
			enemy:AddChill(nil, parent, duration, 15)
		end
	end
end
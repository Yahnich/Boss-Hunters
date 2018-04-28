relic_unique_molten_crystal = class({})

function relic_unique_molten_crystal:OnCreated()
	self:SetStackCount(0)
end

function relic_unique_molten_crystal:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function relic_unique_molten_crystal:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() then
		PrintAll(params)
		local parent = self:GetParent()
		local position = parent:GetCursorPosition()
		if parent:GetCursorTargetingNothing() then position = parent:GetAbsOrigin() end
		
		local damage = parent:GetPrimaryStatValue() * 0.6
		local duration = 8
		local radius = 350
		
		local fireFX = ParticleManager:CreateParticle("particles/units/heroes/hero_lina/lina_lsa_fire.vpcf", PATTACH_WORLDORIGIN, nil)
    	ParticleManager:SetParticleControl(fireFX, 0, position)
    	ParticleManager:SetParticleControl(fireFX, 1, Vector(radius,1,1))
		
		Timers:CreateTimer(1, function()
			for _, enemy in ipairs( parent:FindEnemyUnitsInRadius(position, radius) ) do
				ApplyDamage({victim = enemy, attacker = parent, damage = damage, damage_type = DAMAGE_TYPE_MAGICAL})
			end
			duration = duration - 1
			if duration > 0 then
				return 1
			else
				ParticleManager:ClearParticle( fireFX )
			end
		end)
	end
end

function relic_unique_molten_crystal:GetModifierExtraStrengthBonus()
	return self:GetStackCount()
end

function relic_unique_molten_crystal:IsHidden()
	return true
end

function relic_unique_molten_crystal:IsPurgable()
	return false
end

function relic_unique_molten_crystal:RemoveOnDeath()
	return false
end

function relic_unique_molten_crystal:IsPermanent()
	return true
end

function relic_unique_molten_crystal:AllowIllusionDuplicate()
	return true
end
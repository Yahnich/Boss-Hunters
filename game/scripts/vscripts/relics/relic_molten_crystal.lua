relic_molten_crystal = class(relicBaseClass)

function relic_molten_crystal:OnIntervalThink()
	self:SetDuration(-1, true)
	self:StartIntervalThink(-1)
end

function relic_molten_crystal:OnCreated()
	self:SetStackCount(0)
end

function relic_molten_crystal:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function relic_molten_crystal:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() and params.unit:HasAbility( params.ability:GetName() ) and not params.ability:IsOrbAbility() and self:GetDuration() == -1 then
		--if params.ability:GetBehavior() ~= DOTA_ABILITY_BEHAVIOR_NO_TARGET then
			local parent = self:GetParent()
			local position = parent:GetCursorPosition()
			if parent:GetCursorTargetingNothing() or CalculateDistance( Vector(0,0), position ) < 2 then position = parent:GetAbsOrigin() end
			
			local damage = parent:GetPrimaryStatValue() * 1
			local duration = 8
			local radius = 250
			
			local fireFX = ParticleManager:CreateParticle("particles/relics/molten_crystal/molten_crystal_fire.vpcf", PATTACH_WORLDORIGIN, nil)
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
			
			self:SetDuration(duration+0.1, true)
			self:StartIntervalThink(duration)
		--end
	end
end

function relic_molten_crystal:IsHidden()
	return self:GetDuration() == -1
end
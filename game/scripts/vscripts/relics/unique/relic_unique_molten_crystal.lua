relic_unique_molten_crystal = class({})

function relic_unique_molten_crystal:OnIntervalThink()
	self:SetDuration(-1, true)
	self:StartIntervalThink(-1)
end

function relic_unique_molten_crystal:OnCreated()
	self:SetStackCount(0)
end

function relic_unique_molten_crystal:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function relic_unique_molten_crystal:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() and params.unit:HasAbility( params.ability:GetName() ) and not params.ability:IsOrbAbility() and self:GetDuration() == -1 then
		--if params.ability:GetBehavior() ~= DOTA_ABILITY_BEHAVIOR_NO_TARGET then 
			PrintAll(params)
			local parent = self:GetParent()
			local position = parent:GetCursorPosition()
			if parent:GetCursorTargetingNothing() then position = parent:GetAbsOrigin() end
			
			local damage = parent:GetPrimaryStatValue() * 1
			local duration = 8
			local radius = 250
			
			local fireFX = ParticleManager:CreateParticle("particles/items_fx/molten_crystal/molten_crystal_fire.vpcf", PATTACH_WORLDORIGIN, nil)
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

function relic_unique_molten_crystal:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
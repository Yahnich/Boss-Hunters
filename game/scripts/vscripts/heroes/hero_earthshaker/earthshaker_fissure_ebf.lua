earthshaker_fissure_ebf = class({})

function earthshaker_fissure_ebf:IsStealable()
	return true
end

function earthshaker_fissure_ebf:IsHiddenWhenStolen()
	return false
end

function earthshaker_fissure_ebf:IsVectorTargeting()
	return true
end

function earthshaker_fissure_ebf:GetVectorTargetRange()
	return self:GetTalentSpecialValueFor("fissure_range")
end

function earthshaker_fissure_ebf:GetVectorTargetStartRadius()
	return self:GetTalentSpecialValueFor("fissure_radius")
end

function earthshaker_fissure_ebf:OnAbilityPhaseStart()
	EmitSoundOn( "Hero_EarthShaker.Whoosh", self:GetCaster() )
	return true
end

function earthshaker_fissure_ebf:OnAbilityPhaseInterrupted()
	StopSoundOn( "Hero_EarthShaker.Whoosh", self:GetCaster() )
end

function earthshaker_fissure_ebf:OnVectorCastStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	local fissureDuration = self:GetTalentSpecialValueFor("fissure_duration")
	local damage = self:GetTalentSpecialValueFor("damage")
	local stunDuration = self:GetTalentSpecialValueFor("stun_duration")
	
	EmitSoundOn( "Hero_EarthShaker.Fissure", caster )
	
	local direction = self:GetVectorDirection()
	if direction:Length2D() == 0 then
		direction = CalculateDirection( self:GetVectorPosition(), caster )
	end
	
	local psoList = self:LaunchFissure(self:GetVectorPosition(), direction, fissureDuration, damage, stunDuration)
	Timers:CreateTimer(fissureDuration, function()
		for _, entity in pairs(psoList) do
			if not entity:IsNull() then
				EmitSoundOn( "Hero_EarthShaker.FissureDestroy", entity )
				UTIL_Remove(entity) 
			end
		end
		local retry
		for _, entity in pairs(psoList) do
			if entity:IsNull() then 
				psoList[_] = nil
			else
				retry = 0.1
			end
		end
		return retry
	end)
end

PSO_RADIUS = 128

function earthshaker_fissure_ebf:LaunchFissure(position, direction, fissureDuration, damage, stunDuration)
	local deleteTable = {}
	local caster = self:GetCaster()
	local count = math.ceil( self:GetVectorTargetRange() / PSO_RADIUS )
	local psoPos = position
	
	local posTable = {}
	for i = 1, count do
		local pso = SpawnEntityFromTableSynchronous('point_simple_obstruction', {origin = GetGroundPosition(psoPos, caster)}) 
		table.insert(deleteTable, pso)
		table.insert(posTable, psoPos)
		psoPos = psoPos + direction * PSO_RADIUS
	end
	local aftershock = caster:FindAbilityByName("earthshaker_aftershock_ebf")
	local echo = caster:FindAbilityByName("earthshaker_echo_slam_ebf")
	local radius = self:GetTalentSpecialValueFor("fissure_radius")
	for _, enemy in ipairs( caster:FindEnemyUnitsInLine(position, psoPos, radius ) ) do
		if not enemy:TriggerSpellAbsorb(self) then
			FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
			self:DealDamage(caster, enemy, damage)
			self:Stun(enemy, stunDuration, false)
			if caster:HasTalent("special_bonus_unique_earthshaker_fissure_ebf_1") then
				aftershock:Aftershock( enemy:GetAbsOrigin(),  radius)
			end
		end
	end
	if caster:HasTalent("special_bonus_unique_earthshaker_fissure_ebf_2") then	
		for _, enemy in ipairs( caster:FindEnemyUnitsInLine(position, psoPos, caster:FindTalentValue("special_bonus_unique_earthshaker_fissure_ebf_2", "radius") ) ) do
			local enemyVector = CalculateDirection( enemy, position )
			local angle = math.acos( enemyVector:Dot(direction) )
			local fissureDirection = (GetPerpendicularVector( direction ) * -enemyVector:Cross(direction).z):Normalized()
			local oppositeLength = math.sin(angle) * CalculateDistance( enemy, position )
			local fissurePosition = enemy:GetAbsOrigin() + fissureDirection:Normalized() * oppositeLength
			local distance = math.min( 500, math.max( 0, CalculateDistance( fissurePosition, enemy ) - (PSO_RADIUS + 32) ) )
			enemy:ApplyKnockBack(fissurePosition, 0.5, 0.5, -distance, 0, caster, self)
		end
	end
	ParticleManager:FireParticle("particles/units/heroes/hero_earthshaker/earthshaker_fissure.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position, [1] = psoPos, [2] = Vector( fissureDuration, 0, 0)})
	return deleteTable
end
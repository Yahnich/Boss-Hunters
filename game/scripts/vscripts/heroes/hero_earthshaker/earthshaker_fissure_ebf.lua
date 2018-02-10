earthshaker_fissure_ebf = class({})

function earthshaker_fissure_ebf:GetCastRange( target, position)
	return self:GetTalentSpecialValueFor("fissure_range")
end
	
function earthshaker_fissure_ebf:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	local fissureDuration = self:GetTalentSpecialValueFor("fissure_duration")
	local damage = self:GetTalentSpecialValueFor("damage")
	local stunDuration = self:GetTalentSpecialValueFor("stun_duration")
	local direction = CalculateDirection( target, caster )
	
	local psoList = self:LaunchFissure(caster:GetAbsOrigin(), direction, fissureDuration, damage, stunDuration)
	Timers:CreateTimer(fissureDuration, function()
		for _, entity in pairs(psoList) do
			if not entity:IsNull() then	UTIL_Remove(entity) end
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
	local count = math.ceil( self:GetTrueCastRange() / PSO_RADIUS )
	local psoPos = position
	for i = 1, count do
		psoPos = psoPos + direction * PSO_RADIUS
		local pso = SpawnEntityFromTableSynchronous('point_simple_obstruction', {origin = GetGroundPosition(psoPos, caster)}) 
		table.insert(deleteTable, pso)
	end
	local aftershock = caster:FindAbilityByName("earthshaker_aftershock_ebf")
	local echo = caster:FindAbilityByName("earthshaker_echo_slam_ebf")
	local radius = self:GetTalentSpecialValueFor("fissure_radius")
	for _, enemy in ipairs( caster:FindEnemyUnitsInLine(position, psoPos, radius ) ) do
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin(), true)
		self:DealDamage(caster, enemy, damage)
		self:Stun(enemy, stunDuration, false)
		if caster:HasTalent("special_bonus_unique_earthshaker_fissure_ebf_1") then
			aftershock:Aftershock( enemy:GetAbsOrigin(),  radius)
		end
		if caster:HasTalent("special_bonus_unique_earthshaker_fissure_ebf_2") then
			echo:ModifyCooldown( caster:FindTalentValue("special_bonus_unique_earthshaker_fissure_ebf_2") )
		end
	end
	ParticleManager:FireParticle("particles/units/heroes/hero_earthshaker/earthshaker_fissure.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position + direction * PSO_RADIUS, [1] = psoPos, [2] = Vector( fissureDuration, 0, 0)})
	return deleteTable
end
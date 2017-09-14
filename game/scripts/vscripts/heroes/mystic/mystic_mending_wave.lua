mystic_mending_wave = class({})

function mystic_mending_wave:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	
	local bounces = self:GetTalentSpecialValueFor("bounces")
	local bounceDelay = self:GetTalentSpecialValueFor("bounce_tick")
	local radius = self:GetTalentSpecialValueFor("search_radius")
	local damage_radius = self:GetTalentSpecialValueFor("damage_radius")
	local healdamage = self:GetSpecialValueFor("healdamage")
	
	local targetTeam = DOTA_UNIT_TARGET_TEAM_FRIENDLY
	if caster:HasTalent("mystic_mending_wave_talent_1") then
		targetTeam = DOTA_UNIT_TARGET_TEAM_BOTH
	end
	
	local internalTable = {}
	internalTable[target:entindex()] = true
	local origin = caster
	Timers:CreateTimer(bounceDelay, function()
		local potTargets = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), radius, {order = FIND_CLOSEST, team = targetTeam})
		ParticleManager:FireRopeParticle("particles/heroes/mystic/mystic_mending_wave.vpcf", PATTACH_POINT_FOLLOW, origin, target)
		if caster:IsSameTeam(target) then
			target:HealEvent(healdamage, self, caster)
			local targets = target:FindEnemyUnitsInRadius(target:GetAbsOrigin(), damage_radius)
			for _, enemy in pairs(targets) do
				self:DealDamage(caster, enemy, healdamage)
			end
		else
			self:DealDamage(caster, target, healdamage)
			local targets = target:FindEnemyUnitsInRadius(target:GetAbsOrigin(), damage_radius)
			for _, ally in pairs(targets) do
				ally:HealEvent(healdamage, self, caster)
			end
		end
		
		EmitSoundOn("Hero_Dazzle.Shadow_Wave", target)
		for _, newTarget in pairs(potTargets) do
			if not internalTable[newTarget:entindex()] then
				origin = target
				target = newTarget
				internalTable[newTarget:entindex()] = true
				if bounces > 0 then 
					return bounceDelay 
				end
			end
		end
	end)
end
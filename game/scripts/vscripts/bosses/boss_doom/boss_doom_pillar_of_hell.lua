boss_doom_pillar_of_hell = class({})

function boss_doom_pillar_of_hell:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	ParticleManager:FireLinearWarningParticle(caster:GetAbsOrigin(), caster:GetAbsOrigin() + CalculateDirection( self:GetCursorPosition(), caster ) * self:GetSpecialValueFor("range"), self:GetSpecialValueFor("radius") * 2 )
	return true
end

function boss_doom_pillar_of_hell:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	local radius = self:GetSpecialValueFor("radius")
	local range = self:GetSpecialValueFor("range")
	local damage = self:GetSpecialValueFor("damage")
	local delay = self:GetSpecialValueFor("raze_delay")
	
	local direction = CalculateDirection( target, caster )
	local position = caster:GetAbsOrigin() + direction * radius / 2
	local distanceTraveled = 0
	Timers:CreateTimer(0, function()
		
		self:CreateRaze(position, damage)
		position = position + direction * radius / 2
		distanceTraveled = distanceTraveled + radius / 2
		if distanceTraveled < range then
			return delay
		end
	end)
end

function boss_doom_pillar_of_hell:CreateRaze(position, damage)
	local caster = self:GetCaster()
	local radius = self:GetSpecialValueFor("radius")
	ParticleManager:FireParticle("particles/econ/items/shadow_fiend/sf_fire_arcana/sf_fire_arcana_shadowraze.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position})
	EmitSoundOnLocationWithCaster(position, "Hero_Nevermore.RequiemOfSouls.Damage", caster)
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius(position, radius) ) do
		self:DealDamage( caster, enemy, damage )
	end
end
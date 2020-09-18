boss_leshrac_cataclysm = class({})

function boss_leshrac_cataclysm:OnAbilityPhaseStart()
	self.strikePos = {}
	local caster = self:GetCaster()
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
		table.insert( self.strikePos, enemy:GetAbsOrigin() )
		ParticleManager:FireWarningParticle( enemy:GetAbsOrigin(), self:GetSpecialValueFor("hit_radius") )
	end
	EmitSoundOn( "Hero_Leshrac.Pulse_Nova", caster )
	return true
end

function boss_leshrac_cataclysm:OnSpellStart()
	local caster = self:GetCaster()
	
	local damage = self:GetSpecialValueFor("damage")
	local radius = self:GetSpecialValueFor("radius")
	
	for _, position in ipairs( self.strikePos ) do
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, -1 ) ) do
			if not enemy:TriggerSpellAbsorb( self ) then
				self:DealDamage( caster, enemy, damage )
			end
		end
		EmitSoundOn( "Hero_Leshrac.Pulse_Nova_Strike", caster )
		StopSound( "Hero_Leshrac.Pulse_Nova", caster )
		ParticleManager:FireParticle( "particles/units/heroes/hero_leshrac/leshrac_pulse_nova.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = position,
																	 [1] = Vector( radius, radius, radius )})
	end
end
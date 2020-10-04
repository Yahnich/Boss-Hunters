boss_vanguard_shin_shatter = class({})

function boss_vanguard_shin_shatter:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle( self:GetCaster():GetAbsOrigin(), self:GetSpecialValueFor("radius") )
	return true
end

function boss_vanguard_shin_shatter:OnSpellStart()
	local caster = self:GetCaster()
	
	local damage = self:GetSpecialValueFor("damage")
	local duration = self:GetSpecialValueFor("stun_duration")
	local radius = self:GetSpecialValueFor("radius")
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), radius ) ) do
		if not enemy:TriggerSpellAbsorb( self ) then
			self:DealDamage( caster, enemy, damage )
			self:Stun(enemy, duration)
		end
	end
	ParticleManager:FireParticle("particles/test_particle/ogre_melee_smash.vpcf", PATTACH_POINT_FOLLOW, caster, {[0] = caster:GetAbsOrigin(), [1] = Vector(radius, 1, 1) })
	EmitSoundOnLocationWithCaster(caster:GetAbsOrigin(), "Ability.MeleeSmashLand", caster)
end
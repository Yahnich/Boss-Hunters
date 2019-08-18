boss_centaur_stomp = class({})

function boss_centaur_stomp:OnAbilityPhaseStart()
	self:GetCaster():EmitSound( "n_creep_Centaur.Stomp" )
	ParticleManager:FireWarningParticle( self:GetCaster():GetAbsOrigin(), self:GetSpecialValueFor("radius") )
	return true
end

function boss_centaur_stomp:OnAbilityPhaseInterrupted()
	self:GetCaster():StopSound( "n_creep_Centaur.Stomp" )
end

function boss_centaur_stomp:OnSpellStart()
	local caster = self:GetCaster()
	
	local position = caster:GetAbsOrigin()
	local duration = self:GetSpecialValueFor("duration")
	local damage = self:GetSpecialValueFor("damage")
	local radius = self:GetSpecialValueFor("radius") 
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius) ) do
		self:Stun( enemy, duration )
		self:DealDamage( caster, enemy, damage )
	end
	ParticleManager:FireParticle("particles/neutral_fx/neutral_centaur_khan_war_stomp.vpcf", PATTACH_ABSORIGIN, caster, {[0] = position, [1] = Vector(radius,1,1)})
end
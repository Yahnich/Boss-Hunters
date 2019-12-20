boss_roshan_sonic_boom = class({})

function boss_roshan_sonic_boom:OnAbilityPhaseStart()
	local distance = self:GetSpecialValueFor("distance")
	local width = self:GetSpecialValueFor("width")
	local startPos = self:GetCaster():GetAbsOrigin()
	local endPos = startPos + CalculateDirection( self:GetCaster():GetCursorPosition(), startPos ) * distance
	ParticleManager:FireLinearWarningParticle( startPos, endPos, width )
	EmitSoundOn( "Roshan.Grunt", self:GetCaster() )
	return true
end

function boss_roshan_sonic_boom:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local direction = CalculateDirection( position, caster )
	local speed = self:GetSpecialValueFor( "speed" )
	local distance = self:GetSpecialValueFor( "distance" )
	local width = self:GetSpecialValueFor( "width" )
	
	self:FireLinearProjectile("particles/units/bosses/boss_roshan/boss_roshan_sonic_boom.vpcf", direction * speed, distance, width)
	EmitSoundOn( "Hero_Invoker.DeafeningBlast", caster )
end

function boss_roshan_sonic_boom:OnProjectileHit( target, position )
	if target and not target:TriggerSpellAbsorb( self ) then
		local caster = self:GetCaster()
		local damage = self:GetSpecialValueFor("damage")
		local duration = self:GetSpecialValueFor("duration")
		target:Disarm(self, caster, duration )
		self:DealDamage( caster, target, damage )
	end
end
boss_clockwerk_spear = class({})

function boss_clockwerk_spear:OnAbilityPhaseStart()
	local startPos = self:GetCaster():GetAbsOrigin()
	local endPos = startPos + CalculateDirection( self:GetCursorPosition(), startPos ) * self:GetTrueCastRange()
	ParticleManager:FireLinearWarningParticle( startPos, endPos, 150 )
	return true
end

function boss_clockwerk_spear:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local distance = self:GetTrueCastRange( )
	local direction = CalculateDirection( self:GetCursorPosition(), caster:GetAbsOrigin() )
	self:FireLinearProjectile("particles/light_spear.vpcf", direction * 600, distance, 75, {}, true, true, 350)
end

function boss_clockwerk_spear:OnProjectileHit( target, position )
	local caster = self:GetCaster()
	if target then
		self:DealDamage( caster, target, self:GetSpecialValueFor("damage") )
		self:Stun(target, self:GetSpecialValueFor("duration"))
	end
	return true
end
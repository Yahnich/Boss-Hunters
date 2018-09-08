boss_genesis_crumple = class({})

function boss_genesis_crumple:OnAbilityPhaseStart()
	ParticleManager:FireWarningParticle( self:GetCursorPosition(), self:GetSpecialValueFor("radius") )
	return true
end

function boss_genesis_crumple:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local radius = self:GetSpecialValueFor("radius")
	local damage = caster:GetAttackDamage() * self:GetSpecialValueFor("damage") / 100
	local stunDur = self:GetSpecialValueFor("stun")
	
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, radius ) ) do
		self:DealDamage( caster, enemy, damage )
		self:Stun( enemy, stunDur )
	end
end
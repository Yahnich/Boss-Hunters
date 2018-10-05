satyr_champion_shockwave = class({})

function satyr_champion_shockwave:OnAbilityPhaseStart()
	local ogPos = self:GetCaster():GetAbsOrigin()
	ParticleManager:FireParticle("particles/neutral_fx/satyr_hellcaller_cast.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster() )
	ParticleManager:FireLinearWarningParticle( ogPos, ogPos + CalculateDirection( self:GetCursorPosition(), ogPos ) * self:GetSpecialValueFor("distance"), self:GetSpecialValueFor("width") )
	return true
end

function satyr_champion_shockwave:OnSpellStart()
	local caster = self:GetCaster()
	local position = self:GetCursorPosition()
	
	local width = self:GetSpecialValueFor("width")
	local distance = self:GetSpecialValueFor("distance")
	local speed = self:GetSpecialValueFor("speed")
	
	caster:EmitSound("n_creep_SatyrHellcaller.Shockwave")
	self:FireLinearProjectile("particles/neutral_fx/satyr_hellcaller.vpcf", speed * CalculateDirection( position, caster ), distance, width)
end

function satyr_champion_shockwave:OnProjectileHit(target, position)
	if target then
		if target:TriggerSpellAbsorb(self) then return true end
		local caster = self:GetCaster()
		local damage = self:GetSpecialValueFor("damage")
		self:DealDamage( caster, target, damage )
		target:EmitSound("n_creep_SatyrHellcaller.Shockwave.Damage")
	end
end
boss1b_spear_pierce = class({})

function boss1b_spear_pierce:GetCooldown(nLevel)
	return self:GetCaster():GetSecondsPerAttack()
end

function boss1b_spear_pierce:OnAbilityPhaseStart()
	ParticleManager:FireLinearWarningParticle(self:GetCaster():GetAbsOrigin(), self:GetCaster():GetAbsOrigin() + CalculateDirection(self:GetCursorPosition(), self:GetCaster()) * self:GetSpecialValueFor("spear_distance"), self:GetSpecialValueFor("spear_width"))
	self:SetOverrideCastPoint( self:GetCaster():GetCastPoint( true ) )
	return true
end

function boss1b_spear_pierce:OnSpellStart()
	local caster = self:GetCaster()
	self:FireLinearProjectile("particles/bosses/boss1b/boss1b_spear_pierce.vpcf", CalculateDirection(self:GetCursorPosition(), caster) * self:GetSpecialValueFor("spear_speed"), self:GetSpecialValueFor("spear_distance"), self:GetSpecialValueFor("spear_width"))
end

function boss1b_spear_pierce:OnProjectileHit(hTarget, vLocation)
	if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
		self:DealDamage(self:GetCaster(), hTarget, self:GetCaster():GetAttackDamage())
		return false
	end
end
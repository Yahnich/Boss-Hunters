boss1b_spear_pin = class({})

function boss1b_spear_pin:OnAbilityPhaseStart()
	ParticleManager:FireLinearWarningParticle(self:GetCaster():GetAbsOrigin(), self:GetCaster():GetAbsOrigin() + CalculateDirection(self:GetCursorPosition(), self:GetCaster()) * self:GetSpecialValueFor("spear_distance"), self:GetSpecialValueFor("spear_width"))
	return true
end

function boss1b_spear_pin:OnSpellStart()
	local caster = self:GetCaster()
	self:FireLinearProjectile("particles/bosses/boss1b/boss1b_spear_pin.vpcf", CalculateDirection(self:GetCursorPosition(), caster) * self:GetSpecialValueFor("spear_speed"), self:GetSpecialValueFor("spear_distance"), self:GetSpecialValueFor("spear_width"))
end

function boss1b_spear_pin:OnProjectileHit(hTarget, vLocation)
	if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
		self:DealDamage(self:GetCaster(), hTarget, self:GetSpecialValueFor("spear_damage"))
		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_stunned_generic", {duration = self:GetSpecialValueFor("stun_duration")})
		return true
	end
end
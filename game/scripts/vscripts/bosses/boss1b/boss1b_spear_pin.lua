boss1b_spear_pin = class({})

function boss1b_spear_pin:OnAbilityPhaseStart()
	ParticleManager:FireLinearWarningParticle(self:GetCaster():GetAbsOrigin(), self:GetCaster():GetAbsOrigin() + CalculateDirection(self:GetCursorPosition(), self:GetCaster()) * self:GetSpecialValueFor("spear_distance"), self:GetSpecialValueFor("spear_width"))
	self.warmupFX = ParticleManager:CreateParticle("particles/units/heroes/hero_skywrath_mage/skywrath_mage_concussive_projectile_warmup.vpcf", PATTACH_POINT_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(self.warmupFX, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_attack1", self:GetCaster():GetAbsOrigin(), true)
	return true
end

function boss1b_spear_pin:OnAbilityPhaseInterrupted()
	ParticleManager:ClearParticle(self.warmupFX)
end

function boss1b_spear_pin:OnSpellStart()
	local caster = self:GetCaster()
	ParticleManager:ClearParticle(self.warmupFX)
	self:FireLinearProjectile("particles/bosses/boss1b/boss1b_spear_pin.vpcf", CalculateDirection(self:GetCursorPosition(), caster) * self:GetSpecialValueFor("spear_speed"), self:GetSpecialValueFor("spear_distance"), self:GetSpecialValueFor("spear_width"))
end

function boss1b_spear_pin:OnProjectileHit(hTarget, vLocation)
	if hTarget and hTarget:TriggerSpellAbsorb(self) then return true end
	if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
		self:DealDamage(self:GetCaster(), hTarget, self:GetSpecialValueFor("spear_damage"))
		hTarget:AddNewModifier(self:GetCaster(), self, "modifier_stunned_generic", {duration = self:GetSpecialValueFor("stun_duration")})
		return true
	end
end
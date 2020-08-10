boss1b_spear_pierce = class({})

function boss1b_spear_pierce:GetCooldown(nLevel)
	return self:GetCaster():GetSecondsPerAttack()
end

function boss1b_spear_pierce:OnAbilityPhaseStart()
	self:SetOverrideCastPoint( self:GetCaster():GetCastPoint( true ) )
	return true
end

function boss1b_spear_pierce:OnSpellStart()
	local caster = self:GetCaster()
	self:FireLinearProjectile("particles/bosses/boss1b/boss1b_spear_pierce.vpcf", CalculateDirection(self:GetCursorPosition(), caster) * self:GetSpecialValueFor("spear_speed"), self:GetSpecialValueFor("spear_distance"), self:GetSpecialValueFor("spear_width"))
end

function boss1b_spear_pierce:OnProjectileHit(hTarget, vLocation)
	if hTarget and hTarget:TriggerSpellAbsorb(self) then return true end
	if hTarget ~= nil and ( not hTarget:IsMagicImmune() ) and ( not hTarget:IsInvulnerable() ) then
		self:DealDamage(self:GetCaster(), hTarget, self:GetCaster():GetAttackDamage() * 1.25, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
		return false
	end
end
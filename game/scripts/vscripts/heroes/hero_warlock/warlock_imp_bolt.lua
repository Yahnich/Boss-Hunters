warlock_imp_bolt = class({})

function warlock_imp_bolt:IsStealable()
	return false
end

function warlock_imp_bolt:IsHiddenWhenStolen()
	return false
end

function warlock_imp_bolt:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	local speed = 1000
	local attachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1

	EmitSoundOn("Hero_Jakiro.LiquidFire", caster)
	self:FireTrackingProjectile("particles/units/heroes/hero_warlock/warlock_imp_bolt.vpcf", target, speed, {}, attachment, true, true, 250)
end

function warlock_imp_bolt:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()
	if hTarget then
		EmitSoundOn("Hero_Jakiro.LiquidFire", hTarget)
		local damage = caster:GetOwner():GetIntellect( false) * self:GetSpecialValueFor("damage")/100
		self:DealDamage(caster, hTarget, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
	end
end
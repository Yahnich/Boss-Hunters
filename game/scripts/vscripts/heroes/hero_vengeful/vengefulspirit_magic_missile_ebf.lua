vengefulspirit_magic_missile_ebf = class({})

function vengefulspirit_magic_missile_ebf:IsStealable()
	return true
end

function vengefulspirit_magic_missile_ebf:IsHiddenWhenStolen()
	return false
end

function vengefulspirit_magic_missile_ebf:GetCooldown(iLvl)
    local cooldown = self.BaseClass.GetCooldown(self, iLvl)
    if self:GetCaster():HasTalent("special_bonus_unique_vengefulspirit_magic_missile_ebf_1") then cooldown = cooldown + self:GetCaster():FindTalentValue("special_bonus_unique_vengefulspirit_magic_missile_ebf_1", "cdr") end
    return cooldown
end

function vengefulspirit_magic_missile_ebf:GetAOERadius()
	return self:GetTalentSpecialValueFor("radius")
end

function vengefulspirit_magic_missile_ebf:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	EmitSoundOn("Hero_VengefulSpirit.MagicMissile", caster)

	self:FireTrackingProjectile("particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf", target, self:GetTalentSpecialValueFor("speed"), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_2, false, true, 100)

	local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"))
	for _,enemy in pairs(enemies) do
		if enemy ~= target then
			self:FireTrackingProjectile("particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf", enemy, self:GetTalentSpecialValueFor("speed"), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_2, false, true, 100)
		end
	end

	if caster:HasTalent("special_bonus_unique_vengefulspirit_magic_missile_ebf_2") then
		Timers:CreateTimer(0.25, function()
			self:FireTrackingProjectile("particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf", target, self:GetTalentSpecialValueFor("speed"), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_2, false, true, 100)
			local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), self:GetTalentSpecialValueFor("radius"))
			for _,enemy in pairs(enemies) do
				if enemy ~= target then
					self:FireTrackingProjectile("particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf", enemy, self:GetTalentSpecialValueFor("speed"), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_2, false, true, 100)
				end
			end
		end)
	end
end

function vengefulspirit_magic_missile_ebf:OnProjectileHit(hTarget, vLocation)
	if hTarget ~= nil and not hTarget:TriggerSpellAbsorb( self ) then
		EmitSoundOn("Hero_VengefulSpirit.MagicMissile", hTarget)
		self:Stun(hTarget, self:GetTalentSpecialValueFor("stun_duration"), false)
		self:DealDamage(self:GetCaster(), hTarget, self:GetTalentSpecialValueFor("damage"), {}, 0)
	end
end
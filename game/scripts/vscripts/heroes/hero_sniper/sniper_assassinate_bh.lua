sniper_assassinate_bh = class({})

function sniper_assassinate_bh:GetCastPoint()
	if self:GetCaster():HasTalent("special_bonus_unique_sniper_assassinate_bh_1") then
		local castPoint = 2 - math.abs(self:GetCaster():FindTalentValue("special_bonus_unique_sniper_assassinate_bh_1")) 
		return castPoint
	end
	return 2
end

function sniper_assassinate_bh:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Ability.AssassinateLoad", self:GetCaster())

	self.nfx = 	ParticleManager:CreateParticle("particles/units/heroes/hero_sniper/sniper_crosshair.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControlEnt(self.nfx, 0, target, PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

	return true
end

function sniper_assassinate_bh:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	EmitSoundOn("Ability.Assassinate", self:GetCaster())
	EmitSoundOn("Hero_Sniper.AssassinateProjectile", self:GetCaster())

	ParticleManager:ClearParticle(self.nfx)

	self:FireTrackingProjectile("particles/units/heroes/hero_sniper/sniper_assassinate.vpcf", target, self:GetTalentSpecialValueFor("speed"), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, false, true, 100)

	if caster:HasTalent("special_bonus_unique_sniper_assassinate_bh_2") then
		local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), caster:FindTalentValue("special_bonus_unique_sniper_assassinate_bh_2"))
		for _,enemy in pairs(enemies) do
			if enemy ~= target then
				self:FireTrackingProjectile("particles/units/heroes/hero_sniper/sniper_assassinate.vpcf", enemy, self:GetTalentSpecialValueFor("speed"), {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, false, true, 100)
			end
		end
	end
end

function sniper_assassinate_bh:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget and not hTarget:TriggerSpellAbsorb( self ) then
		EmitSoundOn("Hero_Sniper.AssassinateDamage", caster)
		self:Stun(hTarget, self:GetTalentSpecialValueFor("ministun_duration"), false)
		self:DealDamage(caster, hTarget, self:GetTalentSpecialValueFor("damage"), {}, 0)
		if caster:HasScepter() then caster:PerformGenericAttack(target, true, nil, nil, true) end
	end
end
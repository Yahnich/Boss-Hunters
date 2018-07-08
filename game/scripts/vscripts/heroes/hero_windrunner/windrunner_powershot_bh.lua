windrunner_powershot_bh = class({})

function windrunner_powershot_bh:IsStealable()
	return true
end

function windrunner_powershot_bh:IsHiddenWhenStolen()
	return false
end

function windrunner_powershot_bh:GetChannelAnimation()
	return ACT_DOTA_CAST_ABILITY_2
end

function windrunner_powershot_bh:GetChannelTime()
	return self:GetTalentSpecialValueFor("channel_time")
end

function windrunner_powershot_bh:OnChannelThink(flInterval)
	self.damage = self.damage + self:GetTalentSpecialValueFor("damage")/self:GetChannelTime()*flInterval
end

function windrunner_powershot_bh:OnChannelFinish(bInterrupted)
	local caster = self:GetCaster()

	ParticleManager:ClearParticle(self.nfx)
	StopSoundOn("Ability.PowershotPull", caster)
	EmitSoundOn("Ability.Powershot", caster)

	caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_2)
	self:FireLinearProjectile("particles/units/heroes/hero_windrunner/windrunner_spell_powershot.vpcf", caster:GetForwardVector() * self:GetTalentSpecialValueFor("arrow_speed"), self:GetTrueCastRange(), self:GetTalentSpecialValueFor("arrow_width"), {ExtraData={damage=self.damage}}, false, true, self:GetTalentSpecialValueFor("vision_radius"))
end

function windrunner_powershot_bh:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()
	local direction = CalculateDirection(pos, caster:GetAbsOrigin())
	self.damage = 0

	EmitSoundOn("Ability.PowershotPull", caster)
	self.nfx = ParticleManager:CreateParticle("particles/econ/items/windrunner/windrunner_ti6/windrunner_spell_powershot_channel_ti6.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControlEnt(self.nfx, 0, caster, PATTACH_POINT_FOLLOW, "bow_mid1", caster:GetAbsOrigin(), true)
				ParticleManager:SetParticleControl(self.nfx, 1, caster:GetAbsOrigin())
				ParticleManager:SetParticleControlForward(self.nfx, 1, direction)
end

function windrunner_powershot_bh:OnProjectileHit(hTarget, vLocation)
	if hTarget then
		EmitSoundOn("Ability.PowershotDamage", hTarget)
		self:DealDamage(self:GetCaster(), hTarget, self.damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
		if not self:GetCaster():HasTalent("special_bonus_unique_windrunner_powershot_bh_2") then
			self.damage = self.damage * (100 - self:GetTalentSpecialValueFor("damage_reduction"))/100
		end
	else
		AddFOWViewer(self:GetCaster():GetTeam(), vLocation, self:GetTalentSpecialValueFor("vision_radius"), self:GetTalentSpecialValueFor("vision_duration"), true)
	end
end

function windrunner_powershot_bh:OnProjectileThink(vLocation)
	GridNav:DestroyTreesAroundPoint(vLocation, self:GetTalentSpecialValueFor("arrow_width"), true)
end
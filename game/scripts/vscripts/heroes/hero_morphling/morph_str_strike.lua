morph_str_strike = class({})
LinkLuaModifier( "modifier_morph_str_strike", "heroes/hero_morphling/morph_str_strike.lua" ,LUA_MODIFIER_MOTION_NONE )

function morph_str_strike:IsStealable()
    return true
end

function morph_str_strike:IsHiddenWhenStolen()
    return false
end

function morph_str_strike:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	self.startPos = caster:GetAbsOrigin()

	self.hitUnits = {}

	EmitSoundOn("Hero_Morphling.AdaptiveStrikeStr.Cast", caster)

	self.nfx =  ParticleManager:CreateParticle("particles/units/heroes/hero_morphling/morphling_hydro_cannon.vpcf", PATTACH_POINT, caster)
				ParticleManager:SetParticleControlEnt(self.nfx, 0, caster, PATTACH_POINT, "attach_hitloc", caster:GetAbsOrigin(), true)

	self:FireLinearProjectile("particles/units/heroes/hero_morphling/morphling_invis_linear_projectile.vpcf", caster:GetForwardVector() * 2000, 1000, 100, {}, false, false, 0)
end

function morph_str_strike:OnProjectileThink(vLocation)
	local radius = 75

	ParticleManager:SetParticleControl(self.nfx, 1, vLocation + Vector(0,0,100))

	GridNav:DestroyTreesAroundPoint(vLocation, radius, false)
end

function morph_str_strike:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget and not hTarget:TriggerSpellAbsorb(self) then
		EmitSoundOn("Hero_Morphling.AdaptiveStrike", caster)
		EmitSoundOn("Hero_Morphling.AdaptiveStrikeStr.Target", hTarget)

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_morphling/morphling_adaptive_strike_str_proj_end.vpcf", PATTACH_POINT, caster)
					ParticleManager:SetParticleControlForward(nfx, 0, CalculateDirection(vLocation, hTarget:GetAbsOrigin()))
					ParticleManager:SetParticleControl(nfx, 1, vLocation)
					ParticleManager:SetParticleControl(nfx, 3, vLocation)
					ParticleManager:ReleaseParticleIndex(nfx)

		local agi = caster:GetAgility()
		local str = caster:GetStrength()

		local percent = math.abs((str-agi)/(str+agi))

		local duration = self:GetTalentSpecialValueFor("stun_max") * percent
		if duration <= self:GetTalentSpecialValueFor("stun_min") then
			duration = self:GetTalentSpecialValueFor("stun_min")
		end

		local distance = self:GetTalentSpecialValueFor("knockback_max") * percent
		if distance <= self:GetTalentSpecialValueFor("knockback_min") then
			distance = self:GetTalentSpecialValueFor("knockback_min")
		end

		if caster:HasTalent("special_bonus_unique_morph_str_strike_2") and hTarget:InWater() then
			duration = duration + 1
		end

		local knockBackDuration = distance/1000

		self:Stun(hTarget, duration, false)
		hTarget:ApplyKnockBack(vLocation, knockBackDuration, knockBackDuration, distance, 0, caster, self, false)

		local damage = self:GetTalentSpecialValueFor("damage") + caster:GetStrength() * self:GetTalentSpecialValueFor("str_mult")

		self:DealDamage(caster, hTarget, self:GetTalentSpecialValueFor("damage"), {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
	else
		ParticleManager:ClearParticle(self.nfx)
	end
end

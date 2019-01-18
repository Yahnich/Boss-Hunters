pl_spirit_lance = class({})
LinkLuaModifier("modifier_pl_spirit_lance_arcane", "heroes/hero_phantom_lancer/pl_spirit_lance", LUA_MODIFIER_MOTION_NONE)

function pl_spirit_lance:IsStealable()
    return true
end

function pl_spirit_lance:IsHiddenWhenStolen()
    return false
end

function pl_spirit_lance:GetCastRange(vLocation, hTarget)
    return self:GetTalentSpecialValueFor("cast_range")
end

function pl_spirit_lance:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    EmitSoundOn("Hero_PhantomLancer.SpiritLance.Throw", caster)

    local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_lancer/phantomlancer_spiritlance_caster.vpcf", PATTACH_POINT, caster)
    			ParticleManager:SetParticleControlEnt(nfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
    			ParticleManager:SetParticleControlEnt(nfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
    			ParticleManager:ReleaseParticleIndex(nfx)

    local speed = 1000

    self.hitUnits = {}

    self.maxBounces = caster:FindTalentValue("special_bonus_unique_pl_spirit_lance_1", "bounces")

    self:FireTrackingProjectile("particles/units/heroes/hero_phantom_lancer/phantomlancer_spiritlance_projectile.vpcf", target, speed, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, false, 0)
end

function pl_spirit_lance:doProjectileHitStuff(hTarget, vLocation)
	local caster = self:GetCaster()

	EmitSoundOn("Hero_PhantomLancer.SpiritLance.Impact", hTarget)

	local damage = self:GetTalentSpecialValueFor("damage")
	local slow_duration = self:GetTalentSpecialValueFor("slow_duration")

	local illusion_duration = self:GetTalentSpecialValueFor("illusion_duration")
	local illusion_in = self:GetTalentSpecialValueFor("illusion_in")
	local illusion_out = self:GetTalentSpecialValueFor("illusion_out")

	hTarget:Paralyze(self, caster, slow_duration)

	self:DealDamage(caster, hTarget, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)

	local callback = (function(image)
		if image ~= nil then
			caster:FindAbilityByName("pl_juxtapose"):GiveFxModifier(image)
			image:SetForwardVector(CalculateDirection(hTarget, image))
		end
	end)

	local image = caster:ConjureImage( vLocation + RandomVector( 72 ), illusion_duration, illusion_out, illusion_in, "", self, true, caster, callback )
end

function pl_spirit_lance:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	local radius = caster:FindTalentValue("special_bonus_unique_pl_spirit_lance_1", "radius")
	local speed = 1000

	if hTarget then
		if caster:HasTalent("special_bonus_unique_pl_spirit_lance_1") then

			if not self.hitUnits[hTarget:entindex()] then

				self:doProjectileHitStuff(hTarget, vLocation)

				local enemies = caster:FindEnemyUnitsInRadius(hTarget:GetAbsOrigin(), radius)
				for _,enemy in pairs(enemies) do
					if self.maxBounces > 1 then
						if enemy ~= hTarget and not self.hitUnits[enemy:entindex()] then
							self:FireTrackingProjectile("particles/units/heroes/hero_phantom_lancer/phantomlancer_spiritlance_projectile.vpcf", enemy, speed, {source = hTarget, origin = hTarget:GetAbsOrigin()}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, false, 0)
							self.maxBounces = self.maxBounces - 1
							break
						end
					end
				end
				self.hitUnits[hTarget:entindex()] = true

			end

		else

			self:doProjectileHitStuff(hTarget, vLocation)
		end
	end
end
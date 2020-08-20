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

    self.projectileList = self.projectileList or {}

    local projectile = self:FireTrackingProjectile("particles/units/heroes/hero_phantom_lancer/phantomlancer_spiritlance_projectile.vpcf", target, speed, {}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, false, 0)
	self.projectileList[projectile] = {}
	self.projectileList[projectile].initialTarget = target
	self.projectileList[projectile].hitUnits = {}
	self.projectileList[projectile].maxBounces = caster:FindTalentValue("special_bonus_unique_pl_spirit_lance_1", "bounces")
end

function pl_spirit_lance:doProjectileHitStuff(hTarget, vLocation, projectile)
	local caster = self:GetCaster()

	EmitSoundOn("Hero_PhantomLancer.SpiritLance.Impact", hTarget)

	local damage = self:GetTalentSpecialValueFor("damage")
	local slow_duration = self:GetTalentSpecialValueFor("slow_duration")

	local illusion_duration = self:GetTalentSpecialValueFor("illusion_duration")
	local illusion_in = self:GetTalentSpecialValueFor("illusion_in") - 100
	local illusion_out = self:GetTalentSpecialValueFor("illusion_out") - 100

	hTarget:Paralyze(self, caster, slow_duration)

	self:DealDamage(caster, hTarget, damage, {}, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE)
	if self.projectileList[projectile].initialTarget == hTarget then
		local illusions = caster:ConjureImage( {outgoing_damage = illusion_out, incoming_damage = illusion_in, illusion_modifier = "modifier_phantom_lancer_juxtapose_illusion", position = vLocation + RandomVector( 72 )}, illusion_duration, caster, 1 )
		local image = illusions[1]
		image:AddNewModifier( caster, self, "modifier_pl_juxtapose_illusion", {})
		image:SetForwardVector(CalculateDirection(hTarget, image))
	end
end

function pl_spirit_lance:OnProjectileHitHandle(hTarget, vLocation, iProjectileHandle )
	local caster = self:GetCaster()

	local radius = self:GetTrueCastRange()
	local speed = 1000

	if hTarget and not hTarget:TriggerSpellAbsorb( self ) then
		if not self.projectileList[iProjectileHandle].hitUnits[hTarget:entindex()] then
			self:doProjectileHitStuff(hTarget, vLocation, iProjectileHandle)
			self.projectileList[iProjectileHandle].hitUnits[hTarget:entindex()] = true
			local enemies = caster:FindEnemyUnitsInRadius(hTarget:GetAbsOrigin(), radius, {order = FIND_CLOSEST})
			for _,enemy in pairs(enemies) do
				if self.projectileList[iProjectileHandle].maxBounces > 1 then
					if enemy ~= hTarget and not  self.projectileList[iProjectileHandle].hitUnits[enemy:entindex()] then
						local projectile = self:FireTrackingProjectile("particles/units/heroes/hero_phantom_lancer/phantomlancer_spiritlance_projectile.vpcf", enemy, speed, {source = hTarget, origin = hTarget:GetAbsOrigin()}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, false, 0)
						self.projectileList[projectile] = {}
						self.projectileList[projectile].initialTarget = self.projectileList[iProjectileHandle].hitUnits
						self.projectileList[projectile].hitUnits = self.projectileList[iProjectileHandle].hitUnits
						self.projectileList[projectile].maxBounces =  self.projectileList[iProjectileHandle].maxBounces
						if not enemy:IsMinion() then
							self.projectileList[projectile].maxBounces =  self.projectileList[projectile].maxBounces - 1
						end
						break
					end
				end
			end
		end
	end
end
earthshaker_echo_slam_ebf = class({})

function earthshaker_echo_slam_ebf:IsStealable()
	return true
end

function earthshaker_echo_slam_ebf:IsHiddenWhenStolen()
	return false
end

function earthshaker_echo_slam_ebf:GetCooldown(iLvl)
	local cooldown = self.BaseClass.GetCooldown(self, iLvl) + self:GetCaster():FindTalentValue("special_bonus_unique_earthshaker_echo_slam_ebf_2")
	return cooldown
end

function earthshaker_echo_slam_ebf:GetCastRange( position, target )
	return self:GetSpecialValueFor("search_radius")
end

function earthshaker_echo_slam_ebf:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn( "Hero_EarthShaker.EchoSlam", caster )
	
	ParticleManager:FireParticle("particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start.vpcf", PATTACH_ABSORIGIN, caster, {[1] = Vector(5750,0,0)})
	local baseDamage = self:GetSpecialValueFor("main_damage")
	local echoDamage = self:GetSpecialValueFor("echo_damage")
	local radius = self:GetSpecialValueFor("search_radius")
	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), radius)
	for _, enemy in ipairs( enemies ) do
		if not enemy:TriggerSpellAbsorb(self) then
			self:DealDamage( caster, enemy, baseDamage )
			ParticleManager:FireParticle("particles/units/heroes/hero_earthshaker/earthshaker_echoslam_end.vpcf", PATTACH_POINT_FOLLOW, enemy)
			EmitSoundOn("Hero_EarthShaker.EchoSlamEcho", enemy)
			for _, echoTarget in ipairs( caster:FindEnemyUnitsInRadius( enemy:GetAbsOrigin(), radius) ) do
				if enemy:entindex() ~= echoTarget:entindex() then
					self:CreateEcho( enemy, echoTarget, echoDamage )
				end
			end
		end
	end
end

function earthshaker_echo_slam_ebf:CreateEcho(origin, target, damage)
	local caster = self:GetCaster()
	local info = 
	{
		EffectName = "particles/units/heroes/hero_earthshaker/earthshaker_echoslam.vpcf",
		Target = target,	
		Source = origin,
		Ability = self,	
		iMoveSpeed = 1250,
		vSourceLoc= origin:GetAbsOrigin(),
		bDodgeable = false,
		ExtraData = {damage = damage}
	}
	ProjectileManager:CreateTrackingProjectile(info)
	if caster:HasTalent("special_bonus_unique_earthshaker_echo_slam_ebf_1") then
		Timers:CreateTimer(0.25, function() 
			if target:IsAlive() then
				ProjectileManager:CreateTrackingProjectile(info)
			end
		end)
	end
end

function earthshaker_echo_slam_ebf:OnProjectileHit_ExtraData(target, position, extraData)
	if target then
		local damage = tonumber( extraData.damage )
		self:DealDamage( self:GetCaster(), target, damage )
	end
end
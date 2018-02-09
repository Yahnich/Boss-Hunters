earthshaker_echo_slam_ebf = class({})

function earthshaker_echo_slam_ebf:GetCooldown(iLvl)
	local cooldown = self.BaseClass.GetCooldown(self, iLvl) + self:GetCaster():FindTalentValue("special_bonus_unique_earthshaker_echo_slam_ebf_2")
	return cooldown
end

function earthshaker_echo_slam_ebf:OnSpellStart()
	local caster = self:GetCaster()
	EmitSoundOn( "Hero_EarthShaker.EchoSlam", caster )
	
	ParticleManager:FireParticle("particles/units/heroes/hero_earthshaker/earthshaker_echoslam_start.vpcf", PATTACH_ABSORIGIN, caster, {[1] = Vector(5750,0,0)})
	EmitSoundOn("Hero_EarthShaker.EchoSlam", caster)
	local baseDamage = self:GetTalentSpecialValueFor("main_damage")
	local echoDamage = self:GetTalentSpecialValueFor("echo_damage")
	local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), -1)
	for _, enemy in ipairs( enemies ) do
		local sqRad = ( math.ceil(CalculateDistance(caster, enemy) / 675)^2 )
		local radiusDamage = baseDamage / sqRad
		print( radiusDamage, sqRad )
		self:DealDamage( caster, enemy, radiusDamage )
		ParticleManager:FireParticle("particles/units/heroes/hero_earthshaker/earthshaker_echoslam_end.vpcf", PATTACH_POINT_FOLLOW, enemy)
		for _, echoTarget in ipairs( enemies ) do
			if enemy ~= echoTarget then
				self:CreateEcho( enemy, echoTarget, echoDamage )
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
	EmitSoundOn("Hero_EarthShaker.EchoSlamEcho", caster)
	ProjectileManager:CreateTrackingProjectile(info)
	if caster:HasTalent("special_bonus_unique_earthshaker_echo_slam_ebf_1") then
		Timers:CreateTimer(0.2, function() ProjectileManager:CreateTrackingProjectile(info) end)
	end
end

function earthshaker_echo_slam_ebf:OnProjectileHitUnit_ExtraData(target, position, extraData)
	if target then
		local damage = tonumber( extraData.damage )
		self:DealDamage( self:GetCaster(), target, damage )
	end
end
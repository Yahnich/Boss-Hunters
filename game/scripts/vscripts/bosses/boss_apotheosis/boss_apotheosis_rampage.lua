boss_apotheosis_rampage = class({})

function boss_apotheosis_rampage:OnSpellStart()
	local caster = self:GetCaster()
	
	self.radius = self:GetSpecialValueFor("radius")
	self.damage = self:GetSpecialValueFor("damage")
	caster:AddNewModifier( caster, self, "modifier_boss_apotheosis_rampage", {duration = self:GetSpecialValueFor("duration")})
end

function boss_apotheosis_rampage:OnProjectileHit( target, position )
	if target then
		local caster = self:GetCaster()
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, self.radius ) ) do
			self:DealDamage( caster, enemy, self.damage )
		end
		target:EmitSound("Hero_ObsidianDestroyer.ArcaneOrb.Impact")
		UTIL_Remove(target)
	end
end

function boss_apotheosis_rampage:FireOrb(position)
	local dummy = self:CreateDummy(position)
	local projectile = {
		Target = dummy,
		Source = self:GetCaster(),
		Ability = self,
		EffectName = "particles/units/bosses/boss_apotheosis/boss_apotheosis_rampage.vpcf",
		bDodgable = false,
		bProvidesVision = false,
		iMoveSpeed = CalculateDistance( self:GetCaster(), position ) / self:GetSpecialValueFor("orb_duration"),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1,
	}
	ProjectileManager:CreateTrackingProjectile(projectile)
	EmitSoundOn("Hero_ObsidianDestroyer.ArcaneOrb", self:GetCaster())
	ParticleManager:FireWarningParticle( position, self:GetSpecialValueFor("radius") )
end

modifier_boss_apotheosis_rampage = class({})
LinkLuaModifier("modifier_boss_apotheosis_rampage", "bosses/boss_apotheosis/boss_apotheosis_rampage", LUA_MODIFIER_MOTION_NONE )

function modifier_boss_apotheosis_rampage:OnCreated()
	self.speed = self:GetSpecialValueFor("orb_speed")
	self.interval = self:GetSpecialValueFor("orb_interval")
	self.orbsPerShot = 1 + math.floor( ( 100 - self:GetParent():GetHealthPercent() ) / 20)
	if IsServer() then
		self:StartIntervalThink(self.interval)
	end
end

function modifier_boss_apotheosis_rampage:OnIntervalThink()
	local orbsPerShot = self.orbsPerShot
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local casterPos = caster:GetAbsOrigin()
	for _, hero in ipairs( caster:FindEnemyUnitsInRadius( casterPos, -1 ) ) do
		self:GetAbility():FireOrb(hero:GetAbsOrigin(), self.speed)
		orbsPerShot = orbsPerShot - 1
		if orbsPerShot == 0 then
			break
		end
	end
	if orbsPerShot > 0 then
		for i = 1, orbsPerShot do
			self:GetAbility():FireOrb(casterPos + ActualRandomVector( 1200, 300 ), self.speed )
		end
	end
end

function modifier_boss_apotheosis_rampage:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true}
end

function modifier_boss_apotheosis_rampage:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

function modifier_boss_apotheosis_rampage:GetOverrideAnimation()
	return ACT_DOTA_GENERIC_CHANNEL_1
end
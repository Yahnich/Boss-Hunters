abaddon_brume_spiral = class({})

function abaddon_brume_spiral:IsStealable()
	return true
end

function abaddon_brume_spiral:IsHiddenWhenStolen()
	return false
end

function abaddon_brume_spiral:CastFilterResultTarget(target)
	if target == self:GetCaster() then
		return UF_FAIL_CUSTOM
	else
		return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, target:GetTeamNumber())
	end
end

function abaddon_brume_spiral:GetCustomCastErrorTarget(target)
	return "Cannot target caster"
end

function abaddon_brume_spiral:OnSpellStart()
	-- Variables
	local target = self:GetCursorTarget()
	local caster = self:GetCaster()

	-- Play the ability sound
	caster:EmitSound("Hero_Abaddon.DeathCoil.Cast")

	local heal_pct = self:GetSpecialValueFor( "heal_pct" ) / 100
	local self_damage = math.max( 1, math.floor( caster:GetHealth() * self:GetSpecialValueFor( "self_damage" ) / 100 ) )
	local bounces = self:GetSpecialValueFor( "bounces" )

	local damageDealt = self:DealDamage( caster, caster, self_damage, {damage_type = DAMAGE_TYPE_MAGICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NON_LETHAL })
	if self:GetSpecialValueFor("heal_self_damage") > 0 then
		caster:HealEvent(self_damage, self, caster)
	end
	print( bounces )
	self:CreateMistCoil( target, caster, {bounces = bounces, bonusDamage = damageDealt} )
end

function abaddon_brume_spiral:CreateMistCoil(target, source, bonusData )
	local projectile_speed = self:GetSpecialValueFor( "projectile_speed" )
	self._projectiles = self._projectiles or {}
	local projectile = self:FireTrackingProjectile("particles/units/heroes/hero_abaddon/abaddon_death_coil.vpcf", target, projectile_speed, {source = source}, DOTA_PROJECTILE_ATTACHMENT_HITLOCATION)
	self._projectiles[projectile] = bonusData or {}
end

function abaddon_brume_spiral:OnProjectileHitHandle(target, position, projectile )
	if not target then return end
	if not self._projectiles[projectile] then return end
	local projectileData = table.copy( self._projectiles[projectile] )
	local caster = self:GetCaster()
	
	self._projectiles[projectile] = nil
	
	target:EmitSound("Hero_Abaddon.DeathCoil.Target")
	
	local bonusDamage = projectileData.bonusDamage
	local damage = self:GetSpecialValueFor( "target_damage") + bonusDamage
	local heal = self:GetSpecialValueFor( "heal_amount" )
	PrintAll( projectileData )
	-- If the target and caster are on a different team, do Damage. Heal otherwise
	if target:IsSameTeam( caster ) then
		target:HealEvent(heal, self, caster)
	elseif not target:TriggerSpellAbsorb(self) then
		ApplyDamage({ victim = target, attacker = caster, damage = damage,	damage_type = DAMAGE_TYPE_MAGICAL, ability = self})
	else
		return
	end
	local aoe_radius = self:GetSpecialValueFor("aoe_radiu")
	if aoe_radius > 0 and projectileData.bounces > 0 then
		projectileData.bounces = projectileData.bounces - 1
		local allies = caster:FindFriendlyUnitsInRadius( target:GetAbsOrigin(), aoe_radius )
		local targetAllies = RollPercentage(50) and (#allies > 0)
		if targetAllies then
			for _, ally in ipairs( allies ) do
				if ally:IsRealHero() and not ally:IsFakeHero() and ally ~= target and ally ~= caster then
					self:CreateMistCoil(ally, target, projectileData)
					return
				end
			end
			for _, ally in ipairs( allies ) do
				if ally ~= target and ally ~= caster then
					self:CreateMistCoil(ally, target, projectileData)
					return
				end
			end
		else
			local enemies = caster:FindEnemyUnitsInRadius( target:GetAbsOrigin(), aoe_radius )
			for _, enemy in ipairs( enemies ) do
				if not enemy:IsMinion() and enemy ~= target then
					self:CreateMistCoil(enemy, target, projectileData)
					return
				end
			end
			for _, enemy in ipairs( enemies ) do
				if enemy ~= target then
					self:CreateMistCoil(enemy, target, projectileData)
					return
				end
			end
		end
	end
end
kunkka_ghost_fleet = class({})

KUNKKA_GHOST_SHIP = 1
KUNKKA_CANNONBALL = 2

function kunkka_ghost_fleet:GetAOERadius()
	return self:GetSpecialValueFor("ghostship_width")
end

function kunkka_ghost_fleet:OnSpellStart()
    local caster = self:GetCaster()
    local endPosition = self:GetCursorPosition()
	
    local fleetInterval = self:GetSpecialValueFor("fleet_interval")
    local fleetCount = self:GetSpecialValueFor("fleet_count")
    local driftRadius = self:GetSpecialValueFor("drift_radius")
	
	local crashPosition = endPosition
	Timers:CreateTimer(function()
		self:SummonFleet( caster:GetAbsOrigin(), crashPosition )
		crashPosition = endPosition + ActualRandomVector( driftRadius )
		
		fleetCount = fleetCount - 1
		if fleetCount > 0 then
			return fleetInterval
		end
	end)
end

function kunkka_ghost_fleet:SummonFleet( startPosition, endPosition )

    local width = self:GetSpecialValueFor("ghostship_width")
    local speed = self:GetSpecialValueFor("ghostship_speed")
    local distance = self:GetSpecialValueFor("ghostship_distance")
    local ghostShips = self:GetSpecialValueFor("ghost_ships")

    local damage = self:GetSpecialValueFor("damage")
    local stun_duration = self:GetSpecialValueFor("stun_duration")
    local drag_enemies = self:GetSpecialValueFor("drag_enemies")
	
    local cannons_per_side = self:GetSpecialValueFor("cannons_per_side")
    local cannonade_interval = self:GetSpecialValueFor("cannonade_interval")
    local cannonball_daze_duration = self:GetSpecialValueFor("cannonball_daze_duration")
    local cannonball_damage = self:GetSpecialValueFor("cannonball_damage")
    local cannonball_radius = self:GetSpecialValueFor("cannonball_radius")
    local cannonball_speed = self:GetSpecialValueFor("cannonball_speed")

    local direction = CalculateDirection( endPosition, startPosition )
    direction.z = 0
	local perpendicular = Vector( -direction.y, direction.x )
	
	self._projectiles = self._projectiles or {}
	local evenValue = ((ghostShips+1) % 2)
	local primaryHorizontalOffset = width
	local secondaryHorizontalOffset = (width/2) * evenValue
	local primaryVerticalOffset = 150
	for i = 1, ghostShips do
		local offsetIterator = math.floor((i-evenValue)/2)
		local totalHorizontalOffset = (-1)^i * (secondaryHorizontalOffset + offsetIterator * primaryHorizontalOffset )
		local totalVerticalOffset = offsetIterator * primaryVerticalOffset
		
		local crashPosition = endPosition + totalHorizontalOffset * perpendicular - totalVerticalOffset * direction
		local spawnPosition = crashPosition + direction * -distance
		local ship = self:FireLinearProjectile("particles/units/heroes/hero_kunkka/kunkka_ghost_ship.vpcf", direction * speed, distance, width, {origin = spawnPosition, team = DOTA_UNIT_TARGET_TEAM_BOTH})
		-- nfx
		local marker = ParticleManager:CreateParticle("particles/units/heroes/hero_kunkka/kunkka_ghostship_marker.vpcf", PATTACH_WORLDORIGIN, caster)
		ParticleManager:SetParticleControl(marker, 0, crashPosition)
		ParticleManager:SetParticleControl(marker, 1, Vector(width, width, 0))
		-- init projectile data
		self._projectiles[ship] = {nFX = marker, width = width, damage = damage, stun_duration = stun_duration, drag_enemies = drag_enemies, projectile_type = KUNKKA_GHOST_SHIP}
		if cannons_per_side > 0 then
			self._projectiles[ship].cannons_per_side = cannons_per_side
			self._projectiles[ship].cannonade_interval = cannonade_interval
			self._projectiles[ship].cannonball_daze_duration = cannonball_daze_duration
			self._projectiles[ship].cannonball_damage = cannonball_damage
			self._projectiles[ship].cannonball_radius = cannonball_radius
			self._projectiles[ship].cannonball_speed = cannonball_speed
			self._projectiles[ship].last_cannonade = 0
		end
	end

    EmitSoundOnLocationWithCaster(endPosition, "Ability.Ghostship.bell", caster)
    EmitSoundOnLocationWithCaster(endPosition, "Ability.Ghostship", caster)
end

function kunkka_ghost_fleet:OnProjectileHitHandle( target, position, projectile )
	local caster = self:GetCaster()
    local projectileData = self._projectiles[projectile]
	if not projectileData then return end
	if projectileData.projectile_type == KUNKKA_GHOST_SHIP then
		if target then
			self:TriggerSpellEffect( target )
			if target:IsSameTeam( caster ) then
				
			elseif projectileData.drag_enemies then
				projectileData.dragged_enemies = projectileData.dragged_enemies or {}
				projectileData.dragged_enemies[target] = target:GetAbsOrigin()
			end
		elseif projectileData then
			ParticleManager:ClearParticle(projectileData.nFX)
			EmitSoundOnLocationWithCaster(position, "Ability.Ghostship.crash", caster)
			local enemies = caster:FindEnemyUnitsInRadius(position, projectileData.width)
			for _, enemy in ipairs(enemies) do
				self:DealDamage( caster, enemy, projectileData.damage )
				self:Stun( enemy, projectileData.stun_duration )
				self:TriggerSpellEffect( enemy )
			end
		end
	elseif projectileData.projectile_type == KUNKKA_CANNONBALL and target then
		caster:PerformAbilityAttack(target, true, self, projectileData.cannonball_damage, true, true)
		target:Daze( self, caster, projectileData.daze_duration )
		EmitSoundOn( "Ability.Ghostship.Cannon.Target", target )
	end
	if not target then
		self._projectiles[projectile] = nil
	end
end

function kunkka_ghost_fleet:OnProjectileThinkHandle( projectile )
    local caster = self:GetCaster()
    local projectileData = self._projectiles[projectile]
    if projectileData then
		local velocity = ProjectileManager:GetLinearProjectileVelocity( projectile ) * FrameTime()
		local projPosition = ProjectileManager:GetLinearProjectileLocation( projectile )
		if projectileData.drag_enemies and projectileData.dragged_enemies then
			local pullSpeed = 375 * FrameTime()
			for enemy, position in pairs( projectileData.dragged_enemies ) do
				local newPosition = position + velocity + CalculateDirection( projPosition, position ) * pullSpeed
				projectileData.dragged_enemies[enemy] = newPosition
				enemy:SetAbsOrigin( newPosition )
			end
		end
		if projectileData.last_cannonade and projectileData.cannonade_interval < GameRules:GetGameTime() - projectileData.last_cannonade then
			for i = 1, projectileData.cannons_per_side do
				local cannonRank = i
				
				local cannonDirection = Vector( -velocity.y, velocity.x ):Normalized()
				Timers:CreateTimer( cannonRank*0.1, function()
					for i = 1, 2 do
						local cannonSide = (-1)^i
						local cannonVelocity = cannonDirection * cannonSide * projectileData.cannonball_speed
						local cannonBallPosition = projPosition + cannonDirection * cannonSide * projectileData.cannonball_radius/2 + velocity:Normalized() * cannonRank * projectileData.cannonball_radius
						local cannonball = self:FireLinearProjectile("particles/units/heroes/hero_kunkka/kunkka_cannonball.vpcf", cannonVelocity, projectileData.cannonball_speed, projectileData.cannonball_radius, {origin = cannonBallPosition})
						self._projectiles[cannonball] = {daze_duration = projectileData.cannonball_daze_duration, damage = projectileData.cannonball_damage, projectile_type = KUNKKA_CANNONBALL}
					end
					EmitSoundOnLocationWithCaster( projPosition, "Ability.Ghostship.Cannon.Fire", caster )
				end)
			end
			projectileData.last_cannonade = GameRules:GetGameTime()
		end
    end
end
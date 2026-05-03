spectre_dimensional_interjection = class({})

function spectre_dimensional_interjection:GetIntrinsicModifierName()
	return "modifier_spectre_dimensional_interjection"
end

function spectre_dimensional_interjection:ShouldUseResources()
	return true
end

function spectre_dimensional_interjection:Spawn()
	self:GetCaster()._dimensionalInterjunction = self
	self:GetCaster().SpawnEcho = function( self, position, echoData ) self._dimensionalInterjunction:SpawnEcho( position, echoData ) end
	self:GetCaster().LaunchShadowPath = function( self, position, pathData ) self._dimensionalInterjunction:LaunchShadowPath( position, pathData ) end
	self:GetCaster().CreateShadowPath = function( self, position, pathData ) self._dimensionalInterjunction:CreateShadowPath( position, pathData ) end
end

function spectre_dimensional_interjection:Blink(position)
	local caster = self:GetCaster()
	local startPos = caster:GetAbsOrigin()
	ParticleManager:FireParticle("particles/units/heroes/hero_spectre/spectre_death.vpcf", PATTACH_ABSORIGIN, caster, {[0] = caster:GetAbsOrigin()})
	
	FindClearSpaceForUnit(caster, position, true)
	ProjectileManager:ProjectileDodge( caster )
	ParticleManager:FireParticle("particles/econ/events/nexon_hero_compendium_2014/blink_dagger_end_glow_nexon_hero_cp_2014.vpcf", PATTACH_ABSORIGIN, caster, {[0] = caster:GetAbsOrigin()})
	caster:EmitSound("Hero_Spectre.HauntCast")
	self:SetCooldown()
	
	if caster:IsRealHero() then
		caster:EmitSound("Hero_Spectre.Reality")
		self:CreateEcho( caster:GetAbsOrigin() )
		self:LaunchShadowPath( startPos )
	end
end

modifier_spectre_dimensional_interjection = class({})
LinkLuaModifier("modifier_spectre_dimensional_interjection", "heroes/hero_spectre/spectre_dimensional_interjection", LUA_MODIFIER_MOTION_NONE)

function modifier_spectre_dimensional_interjection:OnCreated()
	self.search_range = self:GetSpecialValueFor("teleport_distance")
end

function modifier_spectre_dimensional_interjection:OnRefresh()
	self.search_range = self:GetSpecialValueFor("teleport_distance")
end

function modifier_spectre_dimensional_interjection:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ORDER
    }
    return funcs
end

function modifier_spectre_dimensional_interjection:OnOrder(params)
	if IsServer() then	
		local ability = self:GetAbility()
		if ability:IsCooldownReady() and params.unit == self:GetParent() and not self:GetParent():IsRooted() then
			if params.target and ( params.order_type == DOTA_UNIT_ORDER_ATTACK_MOVE or params.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET )
			and params.unit:GetAttackRange() + params.target:GetHullRadius() + params.target:GetCollisionPadding() <= CalculateDistance( params.target, self:GetParent() ) then
				if params.unit:HasModifier("modifier_spectre_spectral_dagger_bh") and params.unit:HasModifier("modifier_spectre_spectral_dagger_bh") then
					local attackPos = params.target:GetAbsOrigin()
					local position = attackPos + CalculateDirection( params.unit, attackPos ) * params.unit:GetAttackRange()
					ability:Blink( position )
				elseif CalculateDistance( params.target, self:GetParent() ) >= self.search_range then
					local parentPos = self:GetParent():GetAbsOrigin()
					local position = parentPos + CalculateDirection( params.target, parentPos ) * self.search_range
					ability:Blink( position )
				end
			end
			if ( params.order_type == DOTA_UNIT_ORDER_CAST_TARGET or params.order_type == DOTA_UNIT_ORDER_CAST_POSITION )
			and params.ability:GetCooldown( params.ability:GetLevel() ) > 0 then
				local parentPos = self:GetParent():GetAbsOrigin()
				local distance = CalculateDistance( params.new_pos, parentPos )
				local direction = CalculateDirection( params.new_pos, parentPos )
				if params.target then
					distance = CalculateDistance( params.target, parentPos )
					direction = CalculateDirection( params.target, parentPos )
				end
				local range = math.max( self.search_range, params.ability:GetTrueCastRange() )
				if distance >= range then
					local position = parentPos + direction * self.search_range
					ability:Blink( position )
				end
			end
		end
	end
end

function modifier_spectre_dimensional_interjection:IsHidden()
	return true
end

function spectre_dimensional_interjection:LaunchShadowPath( target, pathData )
	local caster = self:GetCaster()
	local tmpPathData = pathData or {}
	
	local direction = CalculateDirection( target , tmpPathData.origin or caster )
	local radius = tmpPathData.radius or self:GetSpecialValueFor("path_radius")
	local vision = tmpPathData.vision or radius
	local speed = tmpPathData.speed or self:GetSpecialValueFor("path_speed")
	local distance = tmpPathData.distance or CalculateDistance( caster, target )
	local duration = tmpPathData.duration or self:GetSpecialValueFor("path_duration")
	
	self.projectiles = self.projectiles or {}
	local pID
	if not target.GetAbsOrigin then
		pID = self:FireLinearProjectile("particles/units/heroes/hero_spectre/spectre_spectral_dagger.vpcf", direction * speed, distance, radius*2, {source = origin}, false, true, vision)
	else -- unit targeted
		pID = self:FireTrackingProjectile("particles/units/heroes/hero_spectre/spectre_spectral_dagger_tracking.vpcf", target, speed, {source = origin}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, false, true, vision)
	end
	self.projectiles[pID] = {duration = duration, damage = damage, tracking = target.GetAbsOrigin ~= nil, thinkTime = 1 / ( speed/(radius*2) ), currentThink = 0, units = {}, radius = radius }
end

function spectre_dimensional_interjection:CreateShadowPath( position, pathData )
	local caster = self:GetCaster()
	local tmpPathData = pathData or {}
	
	local radius = tmpPathData.radius or self:GetSpecialValueFor("path_radius")
	local vision = tmpPathData.vision or radius
	local duration = tmpPathData.duration or self:GetSpecialValueFor("path_duration")
	local movespeed = tmpPathData.movespeed or self:GetSpecialValueFor("path_movespeed")
	
	CreateModifierThinker( caster, self, "modifier_spectre_dimensional_interjection_shadow_path_thinker", {duration = duration, radius = radius, movespeed = movespeed, vision = vision}, position, caster:GetTeamNumber(), false )
end


function spectre_dimensional_interjection:OnProjectileThinkHandle( projectile )
	local caster = self:GetCaster()
	local projectileData = self.projectiles[projectile]
	if projectileData then
		if projectileData.currentThink <= 0 then
			local position = ProjectileManager:GetProjectileLocation( projectile )
			self:CreateShadowPath( position, {radius = projectileData.radius, duration = projectileData.duration} )
			projectileData.currentThink = projectileData.thinkTime
			if projectileData.tracking then
				for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( position, projectileData.radius ) ) do
					if not projectileData.units[enemy] then
						self:OnProjectileHitHandle( enemy, position, projectile, true )
					end
				end
			end
		else
			projectileData.currentThink = projectileData.currentThink - FrameTime()
		end
	end
end

function spectre_dimensional_interjection:OnProjectileHitHandle( target, position, projectile, bNotFinal )
	local caster = self:GetCaster()
	local projectileData = self.projectiles[projectile]
	if target then
		projectileData.units[target] = true
		if target:TriggerSpellAbsorb(self) then return false end
		EmitSoundOn("Hero_Spectre.DaggerImpact", target)
		if projectileData.tracking and not bNotFinal then
			table.remove( self.projectiles, projectile )
		end
	else
		table.remove( self.projectiles, projectile )
	end
	if self._hookedShadowPathAbilities then
		for _, ability in ipairs( self._hookedShadowPathAbilities ) do
			ability:OnShadowPathHit( target, position, projectile, bNotFinal )
		end
	end
end

function spectre_dimensional_interjection:HookInShadowPathEvents( ability )
	self._hookedShadowPathAbilities = self._hookedShadowPathAbilities or {}
	table.insert( self._hookedShadowPathAbilities, ability )
end

modifier_spectre_dimensional_interjection_shadow_path_thinker = class({})
LinkLuaModifier("modifier_spectre_dimensional_interjection_shadow_path_thinker", "heroes/hero_spectre/modifier_spectre_dimensional_interjection", LUA_MODIFIER_MOTION_NONE)

function modifier_spectre_dimensional_interjection_shadow_path_thinker:OnCreated(kv)
	self.stick = self:GetSpecialValueFor("path_grace_period")
	self.radius = kv.radius or self:GetSpecialValueFor("path_radius")
	if IsServer() then
		AddFOWViewer( self:GetCaster():GetTeam(), self:GetParent():GetAbsOrigin(), kv.vision or self.radius, self:GetRemainingTime(), true )
	end
end

function modifier_spectre_dimensional_interjection_shadow_path_thinker:IsAura()
	return true
end

function modifier_spectre_dimensional_interjection_shadow_path_thinker:GetModifierAura()
	return "modifier_spectre_dimensional_interjection_shadow_path"
end

function modifier_spectre_dimensional_interjection_shadow_path_thinker:GetAuraRadius()
	return self.radius
end

function modifier_spectre_dimensional_interjection_shadow_path_thinker:GetAuraDuration()
	return self.stick
end

function modifier_spectre_dimensional_interjection_shadow_path_thinker:GetAuraSearchTeam()    
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_spectre_dimensional_interjection_shadow_path_thinker:GetAuraSearchType()    
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

function modifier_spectre_dimensional_interjection_shadow_path_thinker:IsHidden()    
	return true
end

modifier_spectre_dimensional_interjection_shadow_path = class({})
LinkLuaModifier("modifier_spectre_dimensional_interjection_shadow_path", "heroes/hero_spectre/modifier_spectre_dimensional_interjection", LUA_MODIFIER_MOTION_NONE)

function modifier_spectre_dimensional_interjection_shadow_path:OnCreated()
	self.slow = self:GetSpecialValueFor("path_movespeed")
	if not self:GetParent():IsSameTeam( self:GetCaster() ) then
		self.slow = self.slow * (-1)
	end
end

function modifier_spectre_dimensional_interjection_shadow_path:CheckState()
	if self:GetParent:GetUnitName() == self:GetCaster():GetUnitName() then
		return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true}
	end
end

function modifier_spectre_dimensional_interjection_shadow_path:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE, MODIFIER_PROPERTY_EVASION_CONSTANT, MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS }
end

function modifier_spectre_dimensional_interjection_shadow_path:GetModifierMoveSpeedBonus_Percentage()
	return self.slow
end

function modifier_spectre_dimensional_interjection_shadow_path:GetModifierMagicalResistanceBonus()
	return self.talent1Mr
end

function modifier_spectre_dimensional_interjection_shadow_path:GetModifierEvasion_Constant()
	return self.talent1Ev
end

function modifier_spectre_dimensional_interjection_shadow_path:GetEffectName()
	if self:GetParent:GetUnitName() == self:GetCaster():GetUnitName() then
		return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_blur.vpcf" 
	end
end

function modifier_spectre_dimensional_interjection:SpawnEcho( position, tEchoData )
	local caster = self:GetCaster()
	local echoData = tEchoData or {}
	local target = echoData.target
	local duration = echoData.echo_duration or self:GetSpecialValueFor("echo_duration")
	local outgoing = echoData.echo_damage_dealt or self:GetSpecialValueFor("echo_damage_dealt") - 100
	local incoming = echoData.echo_damage_taken or self:GetSpecialValueFor("echo_damage_taken") - 100
	
	position = position + RandomVector( caster:GetAttackRange() * 0.75 )
	local illusions = caster:ConjureImage( {outgoing_damage = outgoing, incoming_damage = incoming, position = position, controllable = false}, duration, caster, 1 )
	
	local haunt = illusions[1]
	local attackTarget
	if target then -- entity
		haunt:SetAttacking( target )
		attackTarget = target
		Timers:CreateTimer(0.5, function()
			haunt:SetAttacking( target )
			if not target or target:IsNull() then return end
			ExecuteOrderFromTable({
				UnitIndex = haunt:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = target:entindex()
			})
			if haunt and not haunt:IsNull() and haunt:IsAlive() then
				return 0.5
			end
		end )
	else
		for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( haunt:GetAbsOrigin(), -1, {order = FIND_CLOSEST} ) ) do
			haunt:SetAttacking( enemy )
			attackTarget = enemy
			Timers:CreateTimer(0.5, function()
				if not attackTarget or attackTarget:IsNull() then return end
				ExecuteOrderFromTable({
					UnitIndex = haunt:entindex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = enemy:entindex()
				})
				if haunt and not haunt:IsNull() and haunt:IsAlive() then
					return 0.5
				end
			end )
			break
		end
	end
	
	if attackTarget and echoData.casts_spells then
		for i = 0, haunt:GetAbilityCount() do
			local ability = haunt:GetAbilityByIndex( i )
			if ability and not ability:IsPassive() and ability:GetCooldown( -1 ) > 0 and ability:GetAbilityType() == ABILITY_TYPE_BASIC then
				haunt:SetCursorCastTarget( attackTarget )
				ability:OnSpellStart()
			end
		end
	end
	
	haunt:AddNewModifier( caster, self, "modifier_spectre_dimensional_interjection_echo", {duration = duration-0.1} )
	return haunt
end

modifier_spectre_dimensional_interjection_echo = class({})
LinkLuaModifier( "modifier_spectre_dimensional_interjection_echo", "heroes/hero_spectre/modifier_spectre_dimensional_interjection.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_spectre_dimensional_interjection_echo:IsHidden()
	return true
end
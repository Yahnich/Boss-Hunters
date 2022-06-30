pudge_hook_lua = class({})

function pudge_hook_lua:OnAbilityPhaseStart()
	self:GetCaster():StartGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
	return true
end

function pudge_hook_lua:OnAbilityPhaseInterrupted()
	self:GetCaster():RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
end

function pudge_hook_lua:GetCooldown(iLvl)
	if self:GetCaster():HasScepter() then
		return self:GetTalentSpecialValueFor("scepter_cooldown") 
	else
		return self.BaseClass.GetCooldown(self, iLvl) + self:GetCaster():FindTalentValue("special_bonus_unique_pudge_hook_lua_2")
	end
end

function pudge_hook_lua:OnSpellStart()
	local caster = self:GetCaster()
	
	local direction = CalculateDirection(self:GetCursorPosition(), caster)
	
	-- Play Hook launch sound
	EmitSoundOn("Hero_Pudge.AttackHookExtend", caster)
	
	self.hooks = self.hooks or {}
	self:FireMeatHook(direction)
	
	-- Remove the caster's hook
	local weapon_hook
	if caster:IsHero() then
		weapon_hook = caster:GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
		if weapon_hook ~= nil then
			weapon_hook:AddEffects( EF_NODRAW )
		end
	end
	
	if caster:HasTalent("special_bonus_unique_pudge_hook_lua_2") then
		local bonusHooks = caster:FindTalentValue("special_bonus_unique_pudge_hook_lua_2")
		local angle = caster:FindTalentValue("special_bonus_unique_pudge_hook_lua_2", "angle")
		for i = 1, bonusHooks do
			local newAngle = angle * math.ceil(i / 2) * (-1)^i
			local newDir = RotateVector2D( direction, ToRadians( newAngle ) )
			self:FireMeatHook( newDir )
		end
	end
	if caster:HasTalent("special_bonus_unique_pudge_hook_lua_1") then
		local duration = caster:FindTalentValue("special_bonus_unique_pudge_hook_lua_1", "duration")
		caster:AddNewModifier( caster, self, "modifier_meat_hook_talent", {duration = duration})
	else
		caster:AddNewModifier( caster, self, "modifier_meat_hook_followthrough_lua", {duration = self:GetTrueCastRange() / self:GetTalentSpecialValueFor("speed")})
	end
end

function pudge_hook_lua:FireMeatHook( direction )
	local caster = self:GetCaster()
	-- Parameters
	local hook_speed = self:GetTalentSpecialValueFor("speed")
	local hook_width = self:GetTalentSpecialValueFor("width")
	local hook_range = self:GetTrueCastRange()
	local hook_damage = self:GetTalentSpecialValueFor("damage")
	if caster:HasScepter() then 
		hook_damage = self:GetTalentSpecialValueFor("scepter_damage") 
	end
	local caster_loc = caster:GetAbsOrigin()
	local start_loc = GetGroundPosition(caster_loc + direction * hook_width, caster) + Vector(0,0,100)
	local projectileIndex = self:FireLinearProjectile("", direction * hook_speed, hook_range, hook_width)
	self.hooks[projectileIndex] = {}
	-- Attach the Hook particle
	local hook_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_pudge/pudge_meathook.vpcf", PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleAlwaysSimulate(hook_pfx)
	ParticleManager:SetParticleControlEnt(hook_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_weapon_chain_rt", caster_loc, true)
	ParticleManager:SetParticleControl(hook_pfx, 1, start_loc + direction * hook_range)
	ParticleManager:SetParticleControl(hook_pfx, 2, Vector(hook_speed, hook_range, hook_width))
	ParticleManager:SetParticleControl(hook_pfx, 3, Vector(60, 0, 0))
	ParticleManager:SetParticleControl(hook_pfx, 6, start_loc)
	--why the fuck does this cp work, is not even on the the particle
	ParticleManager:SetParticleControlEnt(hook_pfx, 7, caster, PATTACH_CUSTOMORIGIN, nil, caster_loc, true)
	self.hooks[projectileIndex].particleIndex = hook_pfx
	self.hooks[projectileIndex].hook_speed = hook_speed
	self.hooks[projectileIndex].hook_width = hook_width
	self.hooks[projectileIndex].targets = {}
end

function pudge_hook_lua:OnProjectileHitHandle( target, position, projectileIndex )
	local caster = self:GetCaster()
	if target and target ~= caster then
		for id, hookData in pairs( self.hooks ) do
			for _, unit in ipairs( hookData.targets ) do
				if unit == target then
					return
				end
			end
		end
		local damage = TernaryOperator( self:GetTalentSpecialValueFor("scepter_damage"), caster:HasScepter(), self:GetTalentSpecialValueFor("damage") )
		if target:IsMinion() then
			damage = damage + damage * self:GetTalentSpecialValueFor("minion_damage")/100
		end
		self.hooks[projectileIndex].targets = self.hooks[projectileIndex].targets or {}
		table.insert( self.hooks[projectileIndex].targets, target )
		self:DealDamage( caster, target, damage )
		target:AddNewModifier( caster, self, "modifier_meat_hook_root", {})
	elseif target == caster then
		ParticleManager:ClearParticle(self.hooks[projectileIndex].particleIndex)
		if caster:IsHero() then
			weapon_hook = caster:GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
			if weapon_hook ~= nil then
				weapon_hook:RemoveEffects( EF_NODRAW )
			end
		end
		for i = #self.hooks[projectileIndex].targets, 1, -1 do -- clear modifiers
			local target = self.hooks[projectileIndex].targets[i]
			if target:HasModifier("modifier_meat_hook_root") then target:RemoveModifierByName("modifier_meat_hook_root") end
			if target:HasModifier("modifier_meat_hook_lua") then target:RemoveModifierByName("modifier_meat_hook_lua") end
		end
		ResolveNPCPositions(position, 900)
	elseif target == nil then
		local dummy = caster:CreateDummy(position, 0.1)
		local newProjectile = self:FireTrackingProjectile("", caster, self.hooks[projectileIndex].hook_speed, {origin = position, source = dummy}, nil, false )
		UTIL_Remove( dummy )
		self.hooks[newProjectile] = {}
		self.hooks[newProjectile].targets = {}
		if self.hooks[projectileIndex].targets then
			for _, tTarg in ipairs( self.hooks[projectileIndex].targets ) do
				table.insert( self.hooks[newProjectile].targets, tTarg )
			end
		end
		caster:RemoveGesture( ACT_DOTA_OVERRIDE_ABILITY_1 )
		caster:StartGesture(ACT_DOTA_CHANNEL_ABILITY_1)
		self.hooks[newProjectile].hook_speed = self.hooks[projectileIndex].hook_speed
		self.hooks[newProjectile].hook_width = self.hooks[projectileIndex].hook_width
		self.hooks[newProjectile].particleIndex = self.hooks[projectileIndex].particleIndex
		ParticleManager:SetParticleControl(self.hooks[newProjectile].particleIndex, 1, caster:GetAbsOrigin())
		self.hooks[newProjectile].reelBack = true
		self.hooks[projectileIndex] = nil
		
		caster:RemoveModifierByName("modifier_meat_hook_followthrough_lua")
	end
end

function pudge_hook_lua:OnProjectileThinkHandle( projectileIndex )
	if self.hooks[projectileIndex].reelBack then
		local caster = self:GetCaster()
		local speed = self.hooks[projectileIndex].hook_speed or 0
		local width = self.hooks[projectileIndex].hook_width or 0
		local position = ProjectileManager:GetTrackingProjectileLocation( projectileIndex )
		local projDistance = CalculateDistance( caster, position )
		local projDirection = CalculateDirection( position, caster )
		local perpendicularVect = -GetPerpendicularVector( projDirection )
		for i = #self.hooks[projectileIndex].targets, 1, -1 do -- if enemy is farther away than the hook, try to move them closer, otherwise break the chain if the distance is too far.
			local target = self.hooks[projectileIndex].targets[i]
			local lineSegment = {target:GetAbsOrigin(), target:GetAbsOrigin() - target:GetAbsOrigin() * perpendicularVect * 2000}
			local intersection = FindLineIntersection(lineSegment , {caster:GetAbsOrigin(), position} )
			local distanceToPoint = CalcDistanceToLineSegment2D( target:GetAbsOrigin(), position, caster:GetAbsOrigin() )
			local removed = false
			if distanceToPoint > ( width + target:GetHullRadius() * 2 + target:GetCollisionPadding() * 2 ) then
				if target:HasModifier("modifier_meat_hook_root") then target:RemoveModifierByName("modifier_meat_hook_root") end
				if target:HasModifier("modifier_meat_hook_lua") then target:RemoveModifierByName("modifier_meat_hook_lua") end
				table.remove( self.hooks[projectileIndex].targets, i )
				removed = true
			elseif distanceToPoint > ( target:GetHullRadius() * 2 + target:GetCollisionPadding() * 2 ) then
				local projPoint = FindProjectedPointOnLine( target:GetAbsOrigin(), {caster:GetAbsOrigin(), position} )
				local pushDir = CalculateDirection( projPoint, target:GetAbsOrigin() )
				target:SetAbsOrigin(target:GetAbsOrigin() + pushDir * 550 * FrameTime() )
			end
			if not removed then
				local distance = CalculateDistance( caster, target )
				if projDistance < distance then
					if target:HasModifier("modifier_meat_hook_root") then target:RemoveModifierByName("modifier_meat_hook_root") end
					if not target:HasModifier("modifier_meat_hook_lua") then target:AddNewModifier( caster, self, "modifier_meat_hook_lua", {}) end
					if distance < (caster:GetAttackRange() - 50) then -- break
						if target:HasModifier("modifier_meat_hook_lua") then target:RemoveModifierByName("modifier_meat_hook_lua") end
						table.remove( self.hooks[projectileIndex].targets, i )
					else
						target:SetAbsOrigin(position)
					end
				end
			end
		end
		ParticleManager:SetParticleControl(self.hooks[projectileIndex].particleIndex, 1, caster:GetAbsOrigin())
	end
	
end

modifier_meat_hook_lua = class({})
LinkLuaModifier( "modifier_meat_hook_lua", "heroes/hero_pudge/pudge_hook_lua.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_meat_hook_lua:IsDebuff()
	return true
end

function modifier_meat_hook_lua:IsStunDebuff()
	return true
end

function modifier_meat_hook_lua:RemoveOnDeath()
	return false
end

function modifier_meat_hook_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function modifier_meat_hook_lua:GetOverrideAnimation( params )
	return ACT_DOTA_FLAIL
end

function modifier_meat_hook_lua:CheckState()
	if IsServer() then
		if self:GetCaster() ~= nil and self:GetParent() ~= nil then
			if self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() and ( not self:GetParent():IsMagicImmune() ) then
				local state = {
				[MODIFIER_STATE_STUNNED] = true,
				}

				return state
			else
				local state = {
				[MODIFIER_STATE_ROOTED] = true,
				}
				return state
			end
		end
	end
end

function modifier_meat_hook_lua:IsHidden()
	return true
end

modifier_meat_hook_talent = class({})
LinkLuaModifier( "modifier_meat_hook_talent", "heroes/hero_pudge/pudge_hook_lua.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_meat_hook_talent:OnCreated()
	self:OnRefresh()
end

function modifier_meat_hook_talent:OnRefresh()
	self.evasion = self:GetCaster():FindTalentValue("special_bonus_unique_pudge_hook_lua_1", "value2")
	self.ms = self:GetCaster():FindTalentValue("special_bonus_unique_pudge_hook_lua_1", "value")
end

function modifier_meat_hook_talent:DeclareFunctions()
	return {MODIFIER_PROPERTY_EVASION_CONSTANT, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE}
end

function modifier_meat_hook_talent:GetModifierEvasion_Constant()
	return self.evasion
end

function modifier_meat_hook_talent:GetModifierMoveSpeedBonus_Percentage()
	return self.ms
end

modifier_meat_hook_root = class({})
LinkLuaModifier( "modifier_meat_hook_root", "heroes/hero_pudge/pudge_hook_lua.lua" ,LUA_MODIFIER_MOTION_NONE )
function modifier_meat_hook_root:CheckState()
	return {[MODIFIER_STATE_ROOTED] = true}
end

function modifier_meat_hook_root:GetEffectName()
	return "particles/units/heroes/hero_pudge/pudge_hook_chained.vpcf"
end

modifier_meat_hook_followthrough_lua = class({})
LinkLuaModifier( "modifier_meat_hook_followthrough_lua", "heroes/hero_pudge/pudge_hook_lua.lua" ,LUA_MODIFIER_MOTION_NONE )

function modifier_meat_hook_followthrough_lua:CheckState()
	return {[MODIFIER_STATE_STUNNED] = true}
end

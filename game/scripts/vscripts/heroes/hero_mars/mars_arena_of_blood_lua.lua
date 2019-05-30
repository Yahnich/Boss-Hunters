--Thanks C.H.I.P

mars_arena_of_blood_lua = mars_arena_of_blood_lua or class({})

LinkLuaModifier("modifier_mars_arena_of_blood_lua", "heroes/hero_mars/mars_arena_of_blood_lua.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mars_arena_of_blood_lua_caster", "heroes/hero_mars/mars_arena_of_blood_lua.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mars_arena_of_blood_lua_check_position", "heroes/hero_mars/mars_arena_of_blood_lua.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mars_arena_of_blood_lua_barrier", "heroes/hero_mars/mars_arena_of_blood_lua.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_mars_arena_of_blood_lua_knockback", "heroes/hero_mars/mars_arena_of_blood_lua.lua", LUA_MODIFIER_MOTION_HORIZONTAL)

function mars_arena_of_blood_lua:IsStealable()
	return true
end

function mars_arena_of_blood_lua:IsHiddenWhenStolen()
	return false
end

function mars_arena_of_blood_lua:GetAOERadius()	
	return self:GetSpecialValueFor("radius")		
end

function mars_arena_of_blood_lua:OnSpellStart()			
	if IsServer() then
		-- Ability properties
		local target_point = self:GetCursorPosition()
		local caster = self:GetCaster()		

		-- Ability specials
		local formation_delay = self:GetSpecialValueFor("formation_time")
		local field_radius = self:GetSpecialValueFor("radius")
		local duration = self:GetSpecialValueFor("duration")

		-- Wait for formation to finish setting up
		Timers:CreateTimer(formation_delay, function()
			-- Apply thinker modifier on target location
			CreateModifierThinker(caster, self, "modifier_mars_arena_of_blood_lua", {duration = duration}, target_point, caster:GetTeamNumber(), false)
		end)
	end
end

--Caster buff
modifier_mars_arena_of_blood_lua_caster = modifier_mars_arena_of_blood_lua_caster or class({})

function modifier_mars_arena_of_blood_lua_caster:IsHidden() return false end

function modifier_mars_arena_of_blood_lua_caster:OnCreated(keys)
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_mars_arena_of_blood_lua_caster:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TRANSLATE_ACTIVITY_MODIFIERS
	}

	return funcs
end

function modifier_mars_arena_of_blood_lua_caster:GetActivityTranslationModifiers()
	return 'arena_of_blood'
end

---------------------------------------------------
--				Arena modifier
---------------------------------------------------
modifier_mars_arena_of_blood_lua = modifier_mars_arena_of_blood_lua or class({})

function modifier_mars_arena_of_blood_lua:IsHidden()	return true end

function modifier_mars_arena_of_blood_lua:OnCreated(keys)
	if IsServer() then
		local field_radius = self:GetAbility():GetSpecialValueFor("radius")
		self.aura_radius = field_radius + self:GetSpecialValueFor("spear_distance_from_wall")

		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_mars/mars_arena_of_blood.vpcf", PATTACH_POINT, self:GetCaster())
					ParticleManager:SetParticleControl(nfx, 0, self:GetParent():GetAbsOrigin())
					ParticleManager:SetParticleControl(nfx, 1, Vector(field_radius, 0, 0))
					ParticleManager:SetParticleControl(nfx, 2, self:GetParent():GetAbsOrigin())
					ParticleManager:SetParticleControl(nfx, 3, self:GetParent():GetAbsOrigin())
		self:AttachEffect(nfx)

		self.target_point = self:GetParent():GetAbsOrigin()

		self:StartIntervalThink(FrameTime())
		self:CheckPositions()

		--[[self.spearMen = {}

		local angle = 14

		local maxRaze = 360/angle
		local curRaze = 0

		local direction = self:GetParent():GetForwardVector()

		for i=curRaze,maxRaze do
			direction = RotateVector2D(direction, ToRadians( angle ) )
			local position = self.target_point + direction * field_radius
			position = GetGroundPosition(position, caster)

			local spearGuy = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/mars/mars_soldier.vmdl"})
			spearGuy:SetAbsOrigin(position)
			spearGuy:SetSequence("mars_solider_idle")
			spearGuy:SetForwardVector(-direction)

			table.insert(self.spearMen, spearGuy)
		end]]
	end
end

function modifier_mars_arena_of_blood_lua:OnRemoved()
	if IsServer() then
		--[[for _,spearGuy in pairs(self.spearMen) do
			UTIL_Remove(spearGuy)
		end]]
	end
end

function modifier_mars_arena_of_blood_lua:OnIntervalThink()
	self:CheckPositions()
end

function modifier_mars_arena_of_blood_lua:CheckPositions()
	local nearbyUnits = self:GetCaster():FindEnemyUnitsInRadius(self.target_point, self.aura_radius)
	for _,unit in pairs(nearbyUnits) do
		if not unit:HasModifier("modifier_mars_arena_of_blood_lua_check_position") then
			unit:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_mars_arena_of_blood_lua_check_position", {duration = self:GetRemainingTime(), target_point_x = self.target_point.x, target_point_y = self.target_point.y, target_point_z = self.target_point.z})
		end
	end
end

function modifier_mars_arena_of_blood_lua:IsAura()
    return true
end

function modifier_mars_arena_of_blood_lua:GetAuraDuration()
    return 0.5
end

function modifier_mars_arena_of_blood_lua:GetAuraRadius()
    return self:GetTalentSpecialValueFor("radius")
end

function modifier_mars_arena_of_blood_lua:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_INVULNERABLE
end

function modifier_mars_arena_of_blood_lua:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_mars_arena_of_blood_lua:GetAuraSearchType()
    return DOTA_UNIT_TARGET_ALL
end

function modifier_mars_arena_of_blood_lua:GetAuraEntityReject(hEntity)
    if hEntity ~= self:GetCaster() then
    	return
    end
end

function modifier_mars_arena_of_blood_lua:GetModifierAura()
    return "modifier_mars_arena_of_blood_lua_caster"
end

function modifier_mars_arena_of_blood_lua:IsAuraActiveOnDeath()
    return false
end

-- Area check position
modifier_mars_arena_of_blood_lua_check_position = modifier_mars_arena_of_blood_lua_check_position or class({})

function modifier_mars_arena_of_blood_lua_check_position:IsHidden() return false end

function modifier_mars_arena_of_blood_lua_check_position:OnCreated(keys)
	--fuck you vectors
	self.target_point = Vector(keys.target_point_x, keys.target_point_y, keys.target_point_z)

	if IsServer() then
		self:StartIntervalThink(0.04)
	end
end

function modifier_mars_arena_of_blood_lua_check_position:OnIntervalThink()
	self:kineticize(self:GetCaster(), self:GetParent(), self:GetAbility())
end

function modifier_mars_arena_of_blood_lua_check_position:kineticize(caster, target, ability)
	local radius = ability:GetSpecialValueFor("radius")
	local duration = ability:GetSpecialValueFor("duration")
	local wall_damage = ability:GetSpecialValueFor("spear_damage")
	local wall_hit_distance = ability:GetSpecialValueFor("spear_distance_from_wall")
	local wall_hit_height = 0
	local wall_hit_duration = 0.2
	local center_of_field = self.target_point
	local modifier_barrier = "modifier_mars_arena_of_blood_lua_barrier"

	local direction = CalculateDirection(self:GetParent():GetAbsOrigin(), center_of_field)

	-- Solves for the target's distance from the border of the field (negative is inside, positive is outside)
	local distance = (target:GetAbsOrigin() - center_of_field):Length2D()
	local distance_from_border = distance - radius

	-- The target's angle in the world
	local target_angle = target:GetAnglesAsVector().y

	-- Solves for the target's angle in relation to the center of the circle in radians
	local origin_difference =  center_of_field - target:GetAbsOrigin()
	local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)

	-- Converts the radians to degrees.
	origin_difference_radian = origin_difference_radian * 180
	local angle_from_center = origin_difference_radian / math.pi
	-- Makes angle "0 to 360 degrees" as opposed to "-180 to 180 degrees" aka standard dota angles.
	angle_from_center = angle_from_center + 180.0	
	-- Checks if the target is inside the field
	if distance_from_border < 0 and math.abs(distance_from_border) <= 50 then
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_mars/mars_arena_of_blood_spear.vpcf", PATTACH_POINT, self:GetCaster())
					ParticleManager:SetParticleControl(nfx, 0, target:GetAbsOrigin())
					ParticleManager:SetParticleControlForward(nfx, 0, -direction)
					ParticleManager:ReleaseParticleIndex(nfx)

		target:AddNewModifier(caster, ability, modifier_barrier, {})

		target:ApplyKnockBack(self.target_point, wall_hit_duration, wall_hit_duration, -wall_hit_distance, wall_hit_height, caster, ability, false)
		target:AddNewModifier(caster, ability, "modifier_mars_arena_of_blood_lua_knockback", {duration = wall_hit_duration})
		if target:GetTeam() ~= caster:GetTeam() then
			ability:DealDamage(caster, target, wall_damage)
		end
	-- Checks if the target is outside the field,
	elseif distance_from_border > 0 and math.abs(distance_from_border) <= 60 then
		local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_mars/mars_arena_of_blood_spear.vpcf", PATTACH_POINT, self:GetCaster())
					ParticleManager:SetParticleControl(nfx, 0, target:GetAbsOrigin())
					ParticleManager:SetParticleControlForward(nfx, 0, -direction)
					ParticleManager:ReleaseParticleIndex(nfx)

		target:AddNewModifier(caster, ability, modifier_barrier, {})

		target:ApplyKnockBack(self.target_point, wall_hit_duration, wall_hit_duration, wall_hit_distance, wall_hit_height, caster, ability, false)
		target:AddNewModifier(caster, ability, "modifier_mars_arena_of_blood_lua_knockback", {duration = wall_hit_duration})
		if target:GetTeam() ~= caster:GetTeam() then
			ability:DealDamage(caster, target, wall_damage)
		end
	else
		-- Removes debuffs, so the unit can move freely
		if target:HasModifier(modifier_barrier) then
			target:RemoveModifierByName(modifier_barrier)
		end
	end
end

function modifier_mars_arena_of_blood_lua_check_position:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveModifierByName("modifier_mars_arena_of_blood_lua_barrier")
	end
end

---------------------------------------------------
--			Kinetic Field barrier
---------------------------------------------------

modifier_mars_arena_of_blood_lua_barrier = modifier_mars_arena_of_blood_lua_barrier or class({})

function modifier_mars_arena_of_blood_lua_barrier:IsHidden()	return false end

function modifier_mars_arena_of_blood_lua_barrier:OnCreated()
	if not IsServer() then return end
end

function modifier_mars_arena_of_blood_lua_barrier:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
	}

	return funcs
end

function modifier_mars_arena_of_blood_lua_barrier:GetModifierMoveSpeed_Absolute()
	return 0.1
end

---------------------------------------------------
--			Kinetic Field knockback
---------------------------------------------------

modifier_mars_arena_of_blood_lua_knockback = modifier_mars_arena_of_blood_lua_knockback or class({})

function modifier_mars_arena_of_blood_lua_knockback:IsHidden() return true end
function modifier_mars_arena_of_blood_lua_knockback:IsMotionController()	return true end
function modifier_mars_arena_of_blood_lua_knockback:GetMotionControllerPriority() return DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST end

function modifier_mars_arena_of_blood_lua_knockback:OnCreated( keys )
	if IsServer() then
		--self.target_point = Vector(keys.target_point_x, keys.target_point_y, keys.target_point_z)
		-- self:StartIntervalThink(FrameTime())	
	end
end

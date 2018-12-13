zeus_chain_lightning = class({})
LinkLuaModifier("modifier_zeus_chain_lightning", "heroes/hero_zeus/zeus_chain_lightning", LUA_MODIFIER_MOTION_NONE)

function zeus_chain_lightning:IsStealable()
    return true
end

function zeus_chain_lightning:IsHiddenWhenStolen()
    return false
end

function zeus_chain_lightning:GetBehavior(iLvl)
	if self:GetCaster():HasTalent("special_bonus_unique_zeus_chain_lightning_1") then
		return DOTA_ABILITY_BEHAVIOR_POINT
	end
	return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
end

function zeus_chain_lightning:OnSpellStart()
	local caster = self:GetCaster()
	
	EmitSoundOn("Hero_Zuus.ArcLightning.Cast", caster)
	if caster:HasTalent("special_bonus_unique_zeus_chain_lightning_1") then
		local point = self:GetCursorPosition()
		local direction = CalculateDirection(point, caster:GetAbsOrigin())
		local spawn_point = caster:GetAbsOrigin() + direction * self:GetTrueCastRange()
		local speed = 99999999
		--*Vector(0,0,100)
        if RollPercentage(50) then
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_POINT_FOLLOW, caster, spawn_point, {}, "attach_attack1")
		else
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_POINT_FOLLOW, caster, spawn_point, {}, "attach_attack2")
		end
        self:FireLinearProjectile("", direction*speed, self:GetTrueCastRange(), 125, {}, false, true, 500)

        --Right Side
        local right_QAngle = QAngle(0, -self:GetTalentSpecialValueFor("angle"), 0) 
        local right_spawn_point = RotatePosition(caster:GetAbsOrigin(), right_QAngle, spawn_point)
        local right_direction = CalculateDirection(right_spawn_point, caster:GetAbsOrigin())
        if RollPercentage(50) then
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_POINT_FOLLOW, caster, right_spawn_point, {}, "attach_attack1")
		else
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_POINT_FOLLOW, caster, right_spawn_point, {}, "attach_attack2")
		end
        self:FireLinearProjectile("", right_direction*speed, self:GetTrueCastRange(), 125, {}, false, true, 500)

        --Left Side
        local left_QAngle = QAngle(0, self:GetTalentSpecialValueFor("angle"), 0)
        local left_spawn_point = RotatePosition(caster:GetAbsOrigin(), left_QAngle, spawn_point)
        local left_direction = CalculateDirection(left_spawn_point, caster:GetAbsOrigin())
        if RollPercentage(50) then
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_POINT_FOLLOW, caster, left_spawn_point, {}, "attach_attack1")
		else
			ParticleManager:FireRopeParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_POINT_FOLLOW, caster, left_spawn_point, {}, "attach_attack2")
		end
        self:FireLinearProjectile("", left_direction*speed, self:GetTrueCastRange(), 125, {}, false, true, 500)
	else
		local target = self:GetCursorTarget()
		-- Keeps track of the total number of instances of the ability (increments on cast)
		if self.instance == nil then
			self.instance = 0
			self.strike_bounces = {}
			self.target = {}
		else
			self.instance = self.instance + 1
		end

		-- Sets the total number of jumps for this instance (to be decremented later)
		self.strike_bounces[self.instance] = self:GetTalentSpecialValueFor("jump_count")
		-- Sets the first target as the current target for this instance
		self.target[self.instance] = target

		if RollPercentage(50) then
			if RollPercentage(50) then
				ParticleManager:FireRopeParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_POINT_FOLLOW, caster, target, {}, "attach_attack1", "attach_hitloc")
			else
				ParticleManager:FireRopeParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_POINT_FOLLOW, caster, target, {}, "attach_attack2", "attach_hitloc")
			end
		else
			if RollPercentage(50) then
				ParticleManager:FireRopeParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_head.vpcf", PATTACH_POINT_FOLLOW, caster, target, {}, "attach_attack1", "attach_hitloc")
			else
				ParticleManager:FireRopeParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_head.vpcf", PATTACH_POINT_FOLLOW, caster, target, {}, "attach_attack2", "attach_hitloc")
			end
		end

		target:AddNewModifier(caster, self, "modifier_zeus_chain_lightning", {})
	end
end

function zeus_chain_lightning:OnProjectileHit(hTarget, vLocation)
	local caster = self:GetCaster()

	if hTarget then
		EmitSoundOn("Hero_Zuus.ArcLightning.Target", hTarget)
		self:DealDamage(caster, hTarget, self:GetTalentSpecialValueFor("damage"), {}, 0)
	end
end

modifier_zeus_chain_lightning = class({})
function modifier_zeus_chain_lightning:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetParent()
		local ability = self:GetAbility()
		local jump_delay = self:GetTalentSpecialValueFor("jump_delay")
		local radius = self:GetTalentSpecialValueFor("radius")
		local strike_damage = self:GetTalentSpecialValueFor("damage")
		ability:DealDamage(caster, target, strike_damage, {damage_type = DAMAGE_TYPE_MAGICAL}, 0)	
		target:RemoveModifierByName("modifier_zeus_chain_lightning")

		EmitSoundOn("Hero_Zuus.ArcLightning.Target", target)

		-- Waits on the jump delay
		Timers:CreateTimer(jump_delay,
	    function()
			-- Finds the current instance of the ability by ensuring both current targets are the same
			local current
			for i=0,ability.instance do
				if ability.target[i] ~= nil then
					if ability.target[i] == target then
						current = i
					end
				end
			end
		
			-- Adds a global array to the target, so we can check later if it has already been hit in this instance
			if target.hit == nil then
				target.hit = {}
			end
			-- Sets it to true for this instance
			target.hit[current] = true
		
			-- Decrements our jump count for this instance
			ability.strike_bounces[current] = ability.strike_bounces[current] - 1
		
			-- Checks if there are jumps left
			if ability.strike_bounces[current] > 0 then
				-- Finds units in the radius to jump to
				local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), radius, {})
				local closest = radius
				local new_target
				for _,enemy in ipairs(enemies) do
					-- Positioning and distance variables
					local unit_location = enemy:GetAbsOrigin()
					local vector_distance = target:GetAbsOrigin() - unit_location
					local distance = (vector_distance):Length2D()
					-- Checks if the enemy is closer than the closest checked so far
					if distance < closest then
						-- If the enemy has not been hit yet, we set its distance as the new closest distance and it as the new target
						if enemy.hit == nil then
							new_target = enemy
							closest = distance
						elseif enemy.hit[current] == nil then
							new_target = enemy
							closest = distance
						end
					end
				end
				-- Checks if there is a new target
				if new_target ~= nil then
					-- Creates the particle between the new target and the last target
					if RollPercentage(50) then
						if RollPercentage(50) then
							ParticleManager:FireRopeParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_POINT_FOLLOW, target, new_target, {})
						else
							ParticleManager:FireRopeParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_.vpcf", PATTACH_POINT_FOLLOW, target, new_target, {})
						end
					else
						if RollPercentage(50) then
							ParticleManager:FireRopeParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_head.vpcf", PATTACH_POINT_FOLLOW, target, new_target, {})
						else
							ParticleManager:FireRopeParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning_head.vpcf", PATTACH_POINT_FOLLOW, target, new_target, {})
						end
					end
					-- Sets the new target as the current target for this instance
					ability.target[current] = new_target
					-- Applies the modifer to the new target, which runs this function on it
					new_target:AddNewModifier(caster, ability, "modifier_zeus_chain_lightning", {})

				else
					-- If there are no new targets, we set the current target to nil to indicate this instance is over
					ability.target[current] = nil
				end
			else
				-- If there are no more jumps, we set the current target to nil to indicate this instance is over
				ability.target[current] = nil
			end
		end)
	end
end

function modifier_zeus_chain_lightning:IsHidden()
	return true
end
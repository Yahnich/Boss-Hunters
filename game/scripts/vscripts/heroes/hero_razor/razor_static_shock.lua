razor_static_shock = class({})
LinkLuaModifier("modifier_razor_static_shock_handle", "heroes/hero_razor/razor_static_shock", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_razor_static_shock", "heroes/hero_razor/razor_static_shock", LUA_MODIFIER_MOTION_NONE)

function razor_static_shock:GetIntrinsicModifierName()
	return "modifier_razor_static_shock_handle"
end

modifier_razor_static_shock_handle = class({})
function modifier_razor_static_shock_handle:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	return funcs
end

function modifier_razor_static_shock_handle:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() and params.target:IsAlive() then
			local caster = params.attacker
			local ability = self:GetAbility()
			local target = params.target

			if caster:IsIllusion() then return end
	
			-- Keeps track of the total number of instances of the ability (increments on cast)
			if ability.instance == nil then
				ability.instance = 0
				ability.strike_bounces = {}
				ability.target = {}
			else
				ability.instance = ability.instance + 1
			end
			
			ability.initialTarget = target
			-- Sets the total number of jumps for this instance (to be decremented later)
			ability.strike_bounces[ability.instance] = ability:GetSpecialValueFor("jump_count")
			-- Sets the first target as the current target for this instance
			ability.target[ability.instance] = target

			target:AddNewModifier(caster, ability, "modifier_razor_static_shock", {})
		end
	end
end

function modifier_razor_static_shock_handle:IsHidden()
	return true
end

modifier_razor_static_shock = class({})
function modifier_razor_static_shock:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local target = self:GetParent()
		local ability = self:GetAbility()
		local radius = caster:GetAttackRange()
		
		if counter then
			counter = counter + 1
		else
			counter = 1
		end

		local strike_damage = caster:GetAttackDamage() / counter --self:GetSpecialValueFor("jump_count")
		if target ~= ability.initialTarget then
			ability:DealDamage(caster, target, strike_damage, {damage_type = DAMAGE_TYPE_PHYSICAL}, 0)
		end
		target:RemoveModifierByName("modifier_razor_static_shock")

		EmitSoundOn("Item.Maelstrom.Chain_Lightning.Jump", target)

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
				-- If the enemy has not been hit yet, we set its distance as the new closest distance and it as the new target
				if enemy.hit == nil then
					new_target = enemy
					closest = distance
				elseif enemy.hit[current] == nil then
					new_target = enemy
					closest = distance
				end
			end
			-- Checks if there is a new target
			if new_target ~= nil then
				-- Creates the particle between the new target and the last target
				local nfx = ParticleManager:CreateParticle("particles/units/heroes/hero_razor/razor_base_attack.vpcf", PATTACH_POINT_FOLLOW, caster)
							ParticleManager:SetParticleControlEnt(nfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
							ParticleManager:SetParticleControlEnt(nfx, 1, new_target, PATTACH_POINT_FOLLOW, "attach_hitloc", new_target:GetAbsOrigin(), true)
							ParticleManager:SetParticleControlEnt(nfx, 2, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
							ParticleManager:SetParticleControlEnt(nfx, 9, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
				self:AttachEffect(nfx)
				-- Sets the new target as the current target for this instance
				ability.target[current] = new_target
				-- Applies the modifer to the new target, which runs this function on it
				new_target:AddNewModifier(caster, ability, "modifier_razor_static_shock", {})

			else
				-- If there are no new targets, we set the current target to nil to indicate this instance is over
				ability.target[current] = nil
				counter = 0
			end
		else
			-- If there are no more jumps, we set the current target to nil to indicate this instance is over
			ability.target[current] = nil
			counter = 0
		end
	end
end

function modifier_razor_static_shock:IsHidden()
	return false
end
item_wabbajack = class({})
LinkLuaModifier( "modifier_item_wabbajack_passive", "items/item_wabbajack.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_wabbajack_lightning_damage", "items/item_wabbajack.lua" ,LUA_MODIFIER_MOTION_NONE )

function item_wabbajack:GetIntrinsicModifierName()
	return "modifier_item_wabbajack_passive"
end

modifier_item_wabbajack_passive = class({})
function modifier_item_wabbajack_passive:OnCreated()
	self.chance = self:GetSpecialValueFor("chance")
	self.search_radius = self:GetSpecialValueFor("search_radius")
end

function modifier_item_wabbajack_passive:OnRefresh()
	self.chance = self:GetSpecialValueFor("chance")
	self.search_radius = self:GetSpecialValueFor("search_radius")
end

function modifier_item_wabbajack_passive:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_EXECUTED}
end

function modifier_item_wabbajack_passive:OnAbilityExecuted(params)
	if IsServer() then
		if params.unit == self:GetParent() then
			if self:RollPRNG( self.chance ) then
				local caster = self:GetCaster()

				--Fireball
				if RollPercentage(20) then
					local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self.search_radius)
					for _,enemy in pairs(enemies) do
						self:GetAbility():FireTrackingProjectile("particles/units/heroes/hero_jakiro/jakiro_base_attack_fire.vpcf", enemy, 900, {extradata={projname="fireProj"}}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, true, 100)
						break
					end

				--Chain Lightning
				elseif RollPercentage(40) then
					local ability = self:GetAbility()
					local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self.search_radius)
					for _,enemy in pairs(enemies) do				
						-- Keeps track of the total number of instances of the ability (increments on cast)
						if ability.instance == nil then
							ability.instance = 0
							ability.strike_bounces = {}
							ability.target = {}
						else
							ability.instance = ability.instance + 1
						end
						
						-- Sets the total number of jumps for this instance (to be decremented later)
						ability.strike_bounces[ability.instance] = ability:GetSpecialValueFor("lightning_jump")
						-- Sets the first target as the current target for this instance
						ability.target[ability.instance] = enemy

						ParticleManager:FireRopeParticle("particles/neutral_fx/harpy_chain_lightning.vpcf", PATTACH_POINT_FOLLOW, caster, enemy, {})

						enemy:AddNewModifier(caster, ability, "modifier_item_wabbajack_lightning_damage", {})
					end

				--Frost bolt
				elseif RollPercentage(60) then
					local enemies = caster:FindEnemyUnitsInRadius(caster:GetAbsOrigin(), self.search_radius)
					for _,enemy in pairs(enemies) do
						self:GetAbility():FireTrackingProjectile("particles/base_attacks/ranged_tower_good.vpcf", enemy, 900, {extradata={projname="frostProj"}}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, true, true, 100)
						break
					end

				--Natural Heal
				elseif RollPercentage(80) then
					local allies = caster:FindFriendlyUnitsInRadius(caster:GetAbsOrigin(), self.search_radius)
					for _,ally in pairs(enemies) do
						self:GetAbility():FireTrackingProjectile("particles/units/heroes/hero_treant/treant_leech_seed_projectile.vpcf", ally, 900, {extradata={projname="healProj"}}, DOTA_PROJECTILE_ATTACHMENT_ATTACK_1, false, true, 100)
						break
					end

				--Force Push
				else
					
				end
			end
		end
	end
end

function modifier_item_wabbajack_passive:IsHidden()
	return true
end

modifier_item_wabbajack_lightning_damage = class({})
function modifier_item_wabbajack_lightning_damage:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		local target = self:GetParent()
		local ability = self:GetAbility()
		local jump_delay = 0.25
		local radius = ability:GetSpecialValueFor("lightning_radius")
		local strike_damage = ability:GetSpecialValueFor("lightning_damage")
		ability:DealDamage(caster, target, strike_damage, {damage_type = DAMAGE_TYPE_MAGICAL}, 0)	
		target:RemoveModifierByName("modifier_item_wabbajack_lightning_damage")

		EmitSoundOn("Item.Maelstrom.Chain_Lightning.Jump", target)

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
					ParticleManager:FireRopeParticle("particles/neutral_fx/harpy_chain_lightning.vpcf", PATTACH_POINT_FOLLOW, target, new_target, {})
					-- Sets the new target as the current target for this instance
					ability.target[current] = new_target
					-- Applies the modifer to the new target, which runs this function on it
					new_target:AddNewModifier(caster, ability, "modifier_item_wabbajack_lightning_damage", {})

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

function modifier_item_wabbajack_lightning_damage:IsHidden()
	return true
end
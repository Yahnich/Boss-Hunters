item_voltas_greathammer = class({})
LinkLuaModifier( "modifier_item_voltas_greathammer_handle", "items/item_voltas_greathammer.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_voltas_greathammer_handle_damage", "items/item_voltas_greathammer.lua", LUA_MODIFIER_MOTION_NONE )

function item_voltas_greathammer:GetIntrinsicModifierName()
	return "modifier_item_voltas_greathammer_handle"
end

function item_voltas_greathammer:OnSpellStart()
	local caster = self:GetCaster()

	local damage = caster:GetPrimaryStatValue() * self:GetSpecialValueFor("primary_to_damage") / 100
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( caster:GetAbsOrigin(), -1 ) ) do
		ParticleManager:FireParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_ABSORIGIN, enemy, {[1] = enemy:GetAbsOrigin(), [0] = caster:GetAbsOrigin() + Vector(0,0,1600)})
		EmitSoundOn("Hero_Zuus.LightningBolt", enemy)
		self:DealDamage(caster, enemy, damage)
	end
end

modifier_item_voltas_greathammer_handle = class({})
function modifier_item_voltas_greathammer_handle:OnCreated()
	self.attackspeed = self:GetSpecialValueFor("bonus_attack_speed")
	self.damage = self:GetSpecialValueFor("bonus_damage")
end

function modifier_item_voltas_greathammer_handle:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_voltas_greathammer_handle:DeclareFunctions()
	return {MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_item_voltas_greathammer_handle:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

function modifier_item_voltas_greathammer_handle:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function modifier_item_voltas_greathammer_handle:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() and params.target:IsAlive() and RollPercentage(self:GetSpecialValueFor("strike_chance")) then
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
			
			-- Sets the total number of jumps for this instance (to be decremented later)
			ability.strike_bounces[ability.instance] = ability:GetSpecialValueFor("strike_bounces")
			-- Sets the first target as the current target for this instance
			ability.target[ability.instance] = target

			ParticleManager:FireRopeParticle("particles/items_fx/chain_lightning.vpcf", PATTACH_POINT_FOLLOW, params.attacker, params.target, {})

			target:AddNewModifier(caster, ability, "modifier_item_voltas_greathammer_handle_damage", {})
		end
	end
end

function modifier_item_voltas_greathammer_handle:IsHidden()
	return true
end

function modifier_item_voltas_greathammer_handle:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

modifier_item_voltas_greathammer_handle_damage = class({})
function modifier_item_voltas_greathammer_handle_damage:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		local target = self:GetParent()
		local ability = self:GetAbility()
		local jump_delay = 0.25
		local radius = ability:GetSpecialValueFor("radius")
		local strike_damage = ability:GetSpecialValueFor("strike_damage")
		ability:DealDamage(caster, target, strike_damage, {damage_type = DAMAGE_TYPE_MAGICAL}, 0)	
		target:RemoveModifierByName("modifier_item_voltas_greathammer_handle_damage")

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
					ParticleManager:FireRopeParticle("particles/items_fx/chain_lightning.vpcf", PATTACH_POINT_FOLLOW, target, new_target, {})
					-- Sets the new target as the current target for this instance
					ability.target[current] = new_target
					-- Applies the modifer to the new target, which runs this function on it
					new_target:AddNewModifier(caster, ability, "modifier_item_voltas_greathammer_handle_damage", {})

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

function modifier_item_voltas_greathammer_handle_damage:IsHidden()
	return true
end
item_voltaic_hammer = class({})
LinkLuaModifier( "modifier_item_voltaic_hammer_handle", "items/item_voltaic_hammer.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_voltaic_hammer_handle_damage", "items/item_voltaic_hammer.lua", LUA_MODIFIER_MOTION_NONE )

function item_voltaic_hammer:GetIntrinsicModifierName()
	return "modifier_item_voltaic_hammer_handle"
end

function item_voltaic_hammer:GetAssociatedUpgradeModifier()
	return "modifier_item_battlemaster_staff_passive"
end

function item_voltaic_hammer:ShouldUseResources()
	return true
end

item_voltaic_hammer_2 = class(item_voltaic_hammer)
item_voltaic_hammer_3 = class(item_voltaic_hammer)
item_voltaic_hammer_4 = class(item_voltaic_hammer)
item_voltaic_hammer_5 = class(item_voltaic_hammer)
item_voltaic_hammer_6 = class(item_voltaic_hammer)
item_voltaic_hammer_7 = class(item_voltaic_hammer)
item_voltaic_hammer_8 = class(item_voltaic_hammer)
item_voltaic_hammer_9 = class(item_voltaic_hammer)

modifier_item_voltaic_hammer_handle = class(itemBasicBaseClass)
function modifier_item_voltaic_hammer_handle:OnCreatedSpecific()
	self.chance = self:GetSpecialValueFor("chain_chance")
end

function modifier_item_voltaic_hammer_handle:DeclareFunctions()
	local funcs = self:GetDefaultFunctions()
	table.insert( funcs, MODIFIER_EVENT_ON_ATTACK_LANDED )
	return funcs
end

function modifier_item_voltaic_hammer_handle:CheckState()
	if self.bash then
		return {[MODIFIER_STATE_CANNOT_MISS ] = true}
	end
end

function modifier_item_voltaic_hammer_handle:OnAttackLanded(params)
	if IsServer() then
		self.bash = false
		if params.attacker == self:GetParent() and params.target:IsAlive() and self:GetAbility():IsCooldownReady() and self:RollPRNG( self.chance ) then
			local caster = params.attacker
			local ability = self:GetAbility()
			local target = params.target
			
			-- if caster:IsIllusion() then return end
			self:GetAbility():SetCooldown()
			-- Keeps track of the total number of instances of the ability (increments on cast)
			if ability.instance == nil then
				ability.instance = 0
				ability.strike_bounces = {}
				ability.target = {}
			else
				ability.instance = ability.instance + 1
			end
			
			-- Sets the total number of jumps for this instance (to be decremented later)
			ability.strike_bounces[ability.instance] = ability:GetSpecialValueFor("chain_bounces")
			-- Sets the first target as the current target for this instance
			ability.target[ability.instance] = target

			ParticleManager:FireRopeParticle("particles/items_fx/chain_lightning.vpcf", PATTACH_POINT_FOLLOW, params.attacker, params.target, {})

			target:AddNewModifier(caster, ability, "modifier_item_voltaic_hammer_handle_damage", {})
			self.bash = true
		end
	end
end

modifier_item_voltaic_hammer_handle_damage = class({})
function modifier_item_voltaic_hammer_handle_damage:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		local target = self:GetParent()
		local ability = self:GetAbility()
		local jump_delay = 0.25
		local radius = ability:GetSpecialValueFor("bounce_range")
		local strike_damage = ability:GetSpecialValueFor("chain_damage")
		ability:DealDamage(caster, target, strike_damage, {damage_type = DAMAGE_TYPE_MAGICAL}, 0)
		target:RemoveModifierByName("modifier_item_voltaic_hammer_handle_damage")
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
				print( radius, ability.strike_bounces[current] )
				local enemies = caster:FindEnemyUnitsInRadius(target:GetAbsOrigin(), radius, {})
				local closest = radius
				local new_target
				for _,enemy in ipairs(enemies) do
					if enemy.hit == nil then
						new_target = enemy
						closest = distance
						break
					elseif enemy.hit[current] == nil then
						new_target = enemy
						closest = distance
						break
					end
				end
				-- Checks if there is a new target
				if new_target ~= nil then
					-- Creates the particle between the new target and the last target
					ParticleManager:FireRopeParticle("particles/items_fx/chain_lightning.vpcf", PATTACH_POINT_FOLLOW, target, new_target, {})
					-- Sets the new target as the current target for this instance
					ability.target[current] = new_target
					-- Applies the modifer to the new target, which runs this function on it
					new_target:AddNewModifier(caster, ability, "modifier_item_voltaic_hammer_handle_damage", {})

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

function modifier_item_voltaic_hammer_handle_damage:IsHidden()
	return true
end
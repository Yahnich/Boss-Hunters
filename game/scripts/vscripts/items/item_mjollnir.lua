item_mjollnir = class({})
LinkLuaModifier( "modifier_item_mjollnir_handle", "items/item_mjollnir.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mjollnir_handle_damage", "items/item_mjollnir.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_mjollnir_handle_active", "items/item_mjollnir.lua", LUA_MODIFIER_MOTION_NONE )

function item_mjollnir:GetIntrinsicModifierName()
	return "modifier_item_mjollnir_handle"
end

function item_mjollnir:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_mjollnir_handle_active", {Duration = self:GetSpecialValueFor("duration")})
end

modifier_item_mjollnir_handle = class({})
function modifier_item_mjollnir_handle:OnCreated()
	self.damage = self:GetTalentSpecialValueFor("bonus_damage")
	self.attackspeed = self:GetTalentSpecialValueFor("bonus_attack_speed")
end

function modifier_item_mjollnir_handle:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_mjollnir_handle:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
			MODIFIER_EVENT_ON_ATTACK_LANDED
			}
end

function modifier_item_mjollnir_handle:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function modifier_item_mjollnir_handle:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end

function modifier_item_mjollnir_handle:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() and params.target:IsAlive() and RollPercentage(self:GetSpecialValueFor("chance")) then
			local caster = params.attacker
			local ability = self:GetAbility()
			local target = params.target

			if caster:IsIllusion() then return end
	
			-- Keeps track of the total number of instances of the ability (increments on cast)
			if ability.instance == nil then
				ability.instance = 0
				ability.jump_count = {}
				ability.target = {}
			else
				ability.instance = ability.instance + 1
			end
			
			-- Sets the total number of jumps for this instance (to be decremented later)
			ability.jump_count[ability.instance] = ability:GetSpecialValueFor("jump_count")
			-- Sets the first target as the current target for this instance
			ability.target[ability.instance] = target

			ParticleManager:FireRopeParticle("particles/items_fx/chain_lightning.vpcf", PATTACH_POINT_FOLLOW, params.attacker, params.target, {})

			target:AddNewModifier(caster, ability, "modifier_item_mjollnir_handle_damage", {})
		end
	end
end

function modifier_item_mjollnir_handle:IsHidden()
	return true
end

modifier_item_mjollnir_handle_damage = class({})
function modifier_item_mjollnir_handle_damage:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		local target = self:GetParent()
		local ability = self:GetAbility()
		local jump_delay = 0.25
		local radius = ability:GetSpecialValueFor("jump_radius")
		local jump_damage = ability:GetSpecialValueFor("jump_damage")
		ability:DealDamage(caster, target, jump_damage, {damage_type = DAMAGE_TYPE_MAGICAL}, 0)	
		target:RemoveModifierByName("modifier_item_mjollnir_handle_damage")

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
			ability.jump_count[current] = ability.jump_count[current] - 1
		
			-- Checks if there are jumps left
			if ability.jump_count[current] > 0 then
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
					new_target:AddNewModifier(caster, ability, "modifier_item_mjollnir_handle_damage", {})

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

function modifier_item_mjollnir_handle_damage:IsHidden()
	return true
end

modifier_item_mjollnir_handle_active = class({})
function modifier_item_mjollnir_handle_active:GetTextureName()
	return self.texture
end

function modifier_item_mjollnir_handle_active:OnCreated()
	self.chance = self:GetSpecialValueFor("chance")
	self.damage = self:GetSpecialValueFor("jump_damage")
	self.texture = self:GetAbility():GetAbilityTextureName()
end

function modifier_item_mjollnir_handle_active:OnRefresh()
	self.chance = self:GetSpecialValueFor("chance")
	self.damage = self:GetSpecialValueFor("jump_damage")
	self.texture = self:GetAbility():GetAbilityTextureName()
end

function modifier_item_mjollnir_handle_active:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACKED}
end

function modifier_item_mjollnir_handle_active:OnAttacked(params)
	if params.target == self:GetParent() and params.attacker:IsAlive() and RollPercentage( self.chance ) then
		EmitSoundOn("Item.Maelstrom.Chain_Lightning.Jump", params.attacker)

		ParticleManager:FireRopeParticle("particles/items_fx/chain_lightning.vpcf", PATTACH_POINT_FOLLOW, params.target, params.attacker, {})
		self:GetAbility():DealDamage(params.target, params.attacker, self.damage, {damage_type = DAMAGE_TYPE_MAGICAL}, 0)	
	end
end

function modifier_item_mjollnir_handle_active:GetEffectName()
	return "particles/items2_fx/mjollnir_shield.vpcf"
end

item_mjollnir_2 = class(item_mjollnir)
item_mjollnir_3 = class(item_mjollnir)
item_mjollnir_4 = class(item_mjollnir)
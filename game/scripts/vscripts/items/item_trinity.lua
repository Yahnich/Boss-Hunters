item_trinity = class({})
LinkLuaModifier( "modifier_item_trinity_handle", "items/item_trinity.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_trinity_handle_damage", "items/item_trinity.lua", LUA_MODIFIER_MOTION_NONE )

function item_trinity:GetIntrinsicModifierName()
	return "modifier_item_trinity_handle"
end

function item_trinity:OnSpellStart()
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	
	local duration = self:GetSpecialValueFor("debuff_duration")
	local radius = self:GetSpecialValueFor("debuff_radius")
	EmitSoundOn( "DOTA_Item.VeilofDiscord.Activate", self:GetCaster() )
	ParticleManager:FireParticle("particles/items2_fx/veil_of_discord.vpcf", PATTACH_WORLDORIGIN, nil, {[0] = point, [1] = Vector(radius,1,1)})
	for _, enemy in ipairs( caster:FindEnemyUnitsInRadius( point, radius ) ) do
		ParticleManager:FireParticle("particles/units/heroes/hero_zuus/zuus_lightning_bolt.vpcf", PATTACH_ABSORIGIN, enemy, {[1] = enemy:GetAbsOrigin(), [0] = enemy:GetAbsOrigin() + Vector(0,0,1600)})
		enemy:AddNewModifier(caster, self, "modifier_trinity_debuff", {duration = duration})
		enemy:Paralyze(self, caster, self:GetSpecialValueFor("paralyze_duration"))	
	end
end

modifier_item_trinity_handle = class(itemBaseClass)
function modifier_item_trinity_handle:OnCreated()
	self.damage = self:GetSpecialValueFor("bonus_damage")
	self.regen = self:GetSpecialValueFor("bonus_regen")
	self.castrange = self:GetAbility():GetSpecialValueFor("bonus_cast_range")
	self.spellamp = self:GetAbility():GetSpecialValueFor("bonus_spell_damage")
	self.bonusdamage = self:GetAbility():GetSpecialValueFor("bonus_damage_taken")
	self.int = self:GetAbility():GetSpecialValueFor("bonus_intellect")
	self.manacost = self:GetSpecialValueFor("mana_cost_reduction")
	self.armor = self:GetSpecialValueFor("bonus_armor")
end

function modifier_item_trinity_handle:DeclareFunctions()
	return {
			MODIFIER_EVENT_ON_ATTACK_LANDED,
			MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
			MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
			MODIFIER_PROPERTY_CAST_RANGE_BONUS,
			MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
			MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
			MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
			MODIFIER_PROPERTY_MANACOST_PERCENTAGE}
end


function modifier_item_trinity_handle:GetModifierPercentageManacost()
	return self.manacost
end

function modifier_item_trinity_handle:GetModifierPhysicalArmorBonus()
	return self.armor
end

function modifier_item_trinity_handle:GetModifierPreAttack_BonusDamage()
	return self.damage
end

function modifier_item_trinity_handle:GetModifierConstantHealthRegen()
	return self.regen
end

function modifier_item_trinity_handle:GetModifierCastRangeBonus()
	return self.castrange
end

function modifier_item_trinity_handle:GetModifierSpellAmplify_Percentage()
	return self.spellamp
end

function modifier_item_trinity_handle:GetModifierIncomingDamage_Percentage()
	return self.bonusdamage
end

function modifier_item_trinity_handle:GetModifierBonusStats_Intellect()
	return self.int
end

function modifier_item_trinity_handle:OnAttackLanded(params)
	if IsServer() then
		if params.attacker == self:GetParent() and params.target:IsAlive() and self:RollPRNG(self:GetSpecialValueFor("proc_chance")) then
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
			ability.strike_bounces[ability.instance] = ability:GetSpecialValueFor("proc_bounces")
			-- Sets the first target as the current target for this instance
			ability.target[ability.instance] = target

			ParticleManager:FireRopeParticle("particles/items_fx/chain_lightning.vpcf", PATTACH_POINT_FOLLOW, params.attacker, params.target, {})

			target:AddNewModifier(caster, ability, "modifier_item_trinity_handle_damage", {})
			target:AddNewModifier(caster, ability, "modifier_item_trinity_debuff", {duration = self.duration})
		end
	end
end

function modifier_item_trinity_handle:IsHidden()
	return true
end

modifier_item_trinity_debuff = class({})
LinkLuaModifier("modifier_item_trinity_debuff", "items/item_trinity", LUA_MODIFIER_MOTION_NONE)

function modifier_item_trinity_debuff:OnCreated()
	self.mr = self:GetSpecialValueFor("debuff_mr")
	self.damage = self:GetCaster():GetIntellect() * self:GetSpecialValueFor("debuff_int_dmg") / 100
	self.tick = self:GetSpecialValueFor("debuff_tick_rate")
	if IsServer() then
		self:StartIntervalThink( self.tick )
	end
end

function modifier_item_trinity_debuff:OnRefresh()
	self.mr = self:GetSpecialValueFor("debuff_mr")
	self.damage = self:GetCaster():GetIntellect() * self:GetSpecialValueFor("debuff_int_dmg") / 100
	self.tick = self:GetSpecialValueFor("debuff_tick_rate")
end

function modifier_item_trinity_debuff:OnIntervalThink()
	self:GetAbility():DealDamage( self:GetCaster(), self:GetParent(), self.damage, {damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION} )
end

function modifier_item_trinity_debuff:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_item_trinity_debuff:GetModifierMagicalResistanceBonus()
	return self.mr
end

modifier_item_trinity_handle_damage = class({})
function modifier_item_trinity_handle_damage:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		local target = self:GetParent()
		local ability = self:GetAbility()
		local jump_delay = 0.25
		local radius = ability:GetSpecialValueFor("proc_radius")
		local strike_damage = ability:GetSpecialValueFor("proc_damage")
		
		ability:DealDamage(caster, target, strike_damage, {damage_type = DAMAGE_TYPE_MAGICAL}, 0)	
		target:RemoveModifierByName("modifier_item_trinity_handle_damage")
		local paralyze = ability:GetSpecialValueFor("paralyze_duration")
		target:Paralyze(ability, caster, paralyze)
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
					new_target:AddNewModifier(caster, ability, "modifier_item_trinity_handle_damage", {})

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

function modifier_item_trinity_handle_damage:IsHidden()
	return true
end
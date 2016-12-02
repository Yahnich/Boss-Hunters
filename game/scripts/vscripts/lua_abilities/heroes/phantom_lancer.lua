LinkLuaModifier( "modifier_movespeed_cap", "libraries/modifiers/modifier_movespeed_cap.lua" ,LUA_MODIFIER_MOTION_NONE )

function ApplyBuff(keys)
	local caster = keys.caster
	local target = keys.target
	local caster_origin = caster:GetAbsOrigin()
	
	local ability = keys.ability
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
	local min_distance = ability:GetLevelSpecialValueFor("min_proc_distance", ability:GetLevel() -1)
	local max_distance = ability:GetLevelSpecialValueFor("max_proc_distance", ability:GetLevel() -1)
	local duration = ability:GetLevelSpecialValueFor("buff_duration", ability:GetLevel() -1)
	
	-- Checks if the ability is off cooldown and if the caster is attacking a target
	if target ~= null and ability:IsCooldownReady() then
		-- Checks if the target is an enemy
		if caster:GetTeam() ~= target:GetTeam() then
			local target_origin = target:GetAbsOrigin()
			local distance = math.sqrt((caster_origin.x - target_origin.x)^2 + (caster_origin.y - target_origin.y)^2)
			ability.target = target
			-- Checks if the caster is in range of the target
			if distance >= min_distance and distance <= max_distance then
				local speed_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_lancer/phantom_lancer_dying.vpcf", PATTACH_ABSORIGIN  , keys.caster)
				ParticleManager:SetParticleControl(speed_effect, 0, caster_origin)
				ParticleManager:SetParticleControl(speed_effect, 2, caster_origin)
				ParticleManager:SetParticleControl(speed_effect, 5, caster_origin)
				-- Removes the 522 move speed cap
				caster:AddNewModifier(caster, nil, "modifier_movespeed_cap", { duration = duration })
				-- Apply the speed buff
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_speed_buff", {})
				-- Start cooldown on the passive
				ability:StartCooldown(cooldown)
			-- If the caster is too far from the target, we continuously check his distance until the attack command is canceled
			elseif distance >= max_distance then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_check_distance", {})
			end
		end
	end
end

--[[Author: YOLOSPAGHETTI
	Date: February 16, 2016
	Checks if the caster is in range of the target]]
function DistanceCheck(keys)
	local caster = keys.caster
	local caster_origin = caster:GetAbsOrigin()
	
	local ability = keys.ability
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
	local min_distance = ability:GetLevelSpecialValueFor("min_proc_distance", ability:GetLevel() -1)
	local max_distance = ability:GetLevelSpecialValueFor("max_proc_distance", ability:GetLevel() -1)
	local duration = ability:GetLevelSpecialValueFor("buff_duration", ability:GetLevel() -1)
	
	-- Checks if the caster is still attacking the same target
	if caster:GetAggroTarget() == ability.target then
		local target_origin = ability.target:GetAbsOrigin()
		local distance = math.sqrt((caster_origin.x - target_origin.x)^2 + (caster_origin.y - target_origin.y)^2)
		-- Checks if the caster is in range of the target
		if distance >= min_distance and distance <= max_distance then
			local speed_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_lancer/phantom_lancer_dying.vpcf", PATTACH_ABSORIGIN  , keys.caster)
			ParticleManager:SetParticleControl(speed_effect, 0, caster_origin)
			ParticleManager:SetParticleControl(speed_effect, 2, caster_origin)
			ParticleManager:SetParticleControl(speed_effect, 5, caster_origin)
			-- Removes the 522 move speed cap
			caster:AddNewModifier(caster, nil, "modifier_movespeed_cap", { duration = duration })
			-- Apply the speed buff
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_speed_buff", {})
			-- Start cooldown on the passive
			ability:StartCooldown(cooldown)
			caster:RemoveModifierByName("modifier_check_distance")
		end
	else
		caster:RemoveModifierByName("modifier_check_distance")
	end
end

--[[Author: YOLOSPAGHETTI
	Date: February 16, 2016
	Removes the speed buff if the attack command is canceled]]
function RemoveBuff(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local player = caster:GetPlayerID()
	
	if target == null or target ~= ability.target then
		caster:RemoveModifierByName("modifier_speed_buff")
	end
end

function ConjureImage( event )
	local caster = event.caster
	local ability = event.ability
	local player = caster:GetPlayerID()
	local amount = ability:GetLevelSpecialValueFor( "illusion_amount", ability:GetLevel() - 1 )
	caster:RemoveModifierByName("modifier_speed_buff")
	if not caster:IsIllusion() then
		for i=0,amount-1 do
			local target = event.target
			local unit_name = caster:GetUnitName()
			local origin = target:GetAbsOrigin() + RandomVector(100)
			local duration = ability:GetLevelSpecialValueFor( "illusion_duration", ability:GetLevel() - 1 )
			local outgoingDamage = ability:GetLevelSpecialValueFor( "illusion_outgoing_damage", ability:GetLevel() - 1 )
			local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_incoming_damage", ability:GetLevel() - 1 )

			-- handle_UnitOwner needs to be nil, else it will crash the game.
			local illusion = CreateUnitByName(unit_name, origin, true, caster, nil, caster:GetTeamNumber())
			illusion:SetPlayerID(caster:GetPlayerID())
			illusion:SetControllableByPlayer(player, true)
		
			-- Level Up the unit to the casters level
			local casterLevel = caster:GetLevel()
			for i=1,casterLevel-1 do
				illusion:HeroLevelUp(false)
			end

			-- Set the skill points to 0 and learn the skills of the caster
			illusion:SetAbilityPoints(0)
			illusion:SetAbilityPoints(0)
			for abilitySlot=0,15 do
				local abilityillu = caster:GetAbilityByIndex(abilitySlot)
				if abilityillu ~= nil then 
					local abilityLevel = abilityillu:GetLevel()
					local abilityName = abilityillu:GetAbilityName()
					if illusion:FindAbilityByName(abilityName) ~= nil and abilityName ~= "phantom_lancer_juxtapose" then
						local illusionAbility = illusion:FindAbilityByName(abilityName)
						illusionAbility:SetLevel(abilityLevel)
					end
				end
			end

			-- Recreate the items of the caster
			for itemSlot=0,5 do
				local item = caster:GetItemInSlot(itemSlot)
				if item ~= nil then
					local itemName = item:GetName()
					local newItem = CreateItem(itemName, illusion, illusion)
					illusion:AddItem(newItem)
				end
			end

			-- Set the unit as an illusion
			-- modifier_illusion controls many illusion properties like +Green damage not adding to the unit damage, not being able to cast spells and the team-only blue particle
			illusion:AddNewModifier(caster, ability, "modifier_phantom_lancer_juxtapose_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
			illusion:AddNewModifier(caster, ability, "modifier_illusion", { duration = duration, outgoing_damage = outgoingDamage, incoming_damage = incomingDamage })
			
		
			-- Without MakeIllusion the unit counts as a hero, e.g. if it dies to neutrals it says killed by neutrals, it respawns, etc.
			illusion:MakeIllusion()
		end
	end
end
LinkLuaModifier( "modifier_movespeed_cap", "libraries/modifiers/modifier_movespeed_cap.lua" ,LUA_MODIFIER_MOTION_NONE )

function ApplyBuff(keys)
	local caster = keys.caster
	local target = keys.target
	local caster_origin = caster:GetAbsOrigin()
	local ability = keys.ability
	if ability:GetName() ~= "phantom_lancer_splinter_strike" then ability = caster:FindAbilityByName("phantom_lancer_splinter_strike") end
	local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
	local min_distance = ability:GetTalentSpecialValueFor("min_proc_distance")
	local max_distance = ability:GetTalentSpecialValueFor("max_proc_distance")
	local duration = ability:GetTalentSpecialValueFor("buff_duration")
	-- Checks if the ability is off cooldown and if the caster is attacking a target
	if target ~= null and ability:IsCooldownReady() then
		-- Checks if the target is an enemy
		if caster:GetTeam() ~= target:GetTeam() then
			local target_origin = target:GetAbsOrigin()
			local distance = math.sqrt((caster_origin.x - target_origin.x)^2 + (caster_origin.y - target_origin.y)^2)
			caster.target = target
			-- Checks if the caster is in range of the target
			print(distance >= min_distance, distance <= max_distance, distance, min_distance, max_distance, ability:GetLevel(), ability:GetName())
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
	local min_distance = ability:GetTalentSpecialValueFor("min_proc_distance")
	local max_distance = ability:GetTalentSpecialValueFor("max_proc_distance")
	local duration = ability:GetTalentSpecialValueFor("buff_duration")
	-- Checks if the caster is still attacking the same target
	if caster:GetAggroTarget() == caster.target then
		local target_origin = caster.target:GetAbsOrigin()
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
	if target == nil or target ~= caster.target then
		caster:RemoveModifierByName("modifier_speed_buff")
	end
end

function ConjureImage( event )
	local caster = event.caster
	local ability = event.ability
	local player = caster:GetPlayerID()
	local amount = ability:GetTalentSpecialValueFor( "illusion_amount" )
	caster:RemoveModifierByName("modifier_speed_buff")
	if not caster:IsIllusion() then
		local target = event.target
		local unit_name = caster:GetUnitName()
		local origin = target:GetAbsOrigin() + RandomVector(100)
		local duration = ability:GetTalentSpecialValueFor( "illusion_duration" )
		local outgoingDamage = ability:GetTalentSpecialValueFor( "illusion_outgoing_damage" )
		local incomingDamage = ability:GetTalentSpecialValueFor( "illusion_incoming_damage" )
		for i=1, amount do
			caster:ConjureImage( origin, duration, outgoingDamage, incomingDamage, "modifier_phantom_lancer_juxtapose_illusion" )
		end
	end
end

function ConjureImageAttack( event )
	local caster = event.caster
	local ability = event.ability
	local player = caster:GetPlayerID()
	local amount = ability:GetTalentSpecialValueFor( "illusion_amount" )
	caster:RemoveModifierByName("modifier_speed_buff")
	if caster:IsIllusion() or not ability:IsCooldownReady() then return end
	local target = event.target
	local unit_name = caster:GetUnitName()
	local origin = target:GetAbsOrigin() + RandomVector(100)
	local duration = ability:GetTalentSpecialValueFor( "illusion_duration" )
	local outgoingDamage = ability:GetTalentSpecialValueFor( "illusion_outgoing_damage" )
	local incomingDamage = ability:GetTalentSpecialValueFor( "illusion_incoming_damage" )
	for i=1, amount do
		caster:ConjureImage( origin, duration, outgoingDamage, incomingDamage, "modifier_phantom_lancer_juxtapose_illusion" )
	end
	ability:StartCooldown(ability:GetCooldown(-1))
end
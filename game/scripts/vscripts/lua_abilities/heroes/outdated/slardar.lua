function SlardarCrush( keys )
	local caster = keys.caster
	local target = keys.target
	local caster_location = caster:GetAbsOrigin()
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local modifier = keys.modifier
	-- Distance calculations
	local speed = ability:GetTalentSpecialValueFor("speed")
	local distance = (target_point - caster_location):Length2D()
	local direction = (target_point - caster_location):Normalized()
	local duration = distance/speed

	-- Saving the data in the ability

	ability.distance = distance
	ability.speed = speed * 1/30 -- 1/30 is how often the motion controller ticks
	ability.direction = direction
	ability.traveled_distance = 0
	ability.leap_z = 0
	if caster.bash ~= nil then
		caster.bash = caster.bash + 2
	end
	
	local current_ability = caster:GetAbilityByIndex(2):GetAbilityName()
	
	if current_ability == "slardar_oathkeeper" then
		caster.threat = caster.threat + 8 * ability:GetLevel()
	end
	
	ability:ApplyDataDrivenModifier(caster, caster, modifier, {duration = duration})
end
function SlardarCrushDamage(keys)
	local ability = keys.ability
	ApplyDamage({victim = keys.target, attacker = keys.caster, damage = ability:GetTalentSpecialValueFor("damage"), damage_type = ability:GetAbilityDamageType(), ability = ability})
end
function SlardarCrushHorizontal( keys )
	local caster = keys.target
	local ability = keys.ability
	-- Move the caster while the distance traveled is less than the original distance upon cast
	if ability.traveled_distance < ability.distance then
		caster:SetAbsOrigin(caster:GetAbsOrigin() + ability.direction * ability.speed)
		ability.traveled_distance = ability.traveled_distance + ability.speed
		particle_splash = ParticleManager:CreateParticle("particles/units/heroes/hero_slardar/slardar_loadout_water.vpcf", PATTACH_ABSORIGIN, keys.caster)
		ParticleManager:SetParticleControl(particle_splash, 0, GetGroundPosition(caster:GetAbsOrigin(), caster))
		ParticleManager:SetParticleControl(particle_splash, 1, Vector(200,200,200)) --radius
	else
		-- Remove the motion controller once the distance has been 
		caster:InterruptMotionControllers(false)
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_2)
		particle_splash = ParticleManager:CreateParticle("particles/units/heroes/hero_slardar/slardar_loadout.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)
		ParticleManager:SetParticleControl(particle_splash, 0, GetGroundPosition(caster:GetAbsOrigin(), caster))
		ParticleManager:SetParticleControl(particle_splash, 1, Vector(300,300,3100))
	end
end

function SlardarCrushVertical( keys )
	local caster = keys.caster
	local ability = keys.ability

	if ability.distance > ability.speed*8 then
		if ability.traveled_distance < ability.distance/2 and ability.leap_z > -10*ability.speed  then
			-- Go up
			-- This is to memorize the z point when it comes to cliffs and such although the division of speed by 2 isnt necessary, its more of a cosmetic thing
			ability.leap_z = ability.leap_z - 2*ability.speed
			-- Set the new location to the current ground location + the memorized z point
			caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
		elseif ability.traveled_distance > ability.distance*(8/10) then
			-- Go down
			ability.leap_z = ability.leap_z + ability.speed
			caster:SetAbsOrigin(GetGroundPosition(caster:GetAbsOrigin(), caster) + Vector(0,0,ability.leap_z))
		end
	end
end

function SlardarInit(keys)
	local caster = keys.caster
	if caster.hit == nil then
		caster.hit = 0
	end
	if caster.hitcharge == nil then
		caster.hitcharge = 0
	end
	if caster.bash == nil then
		caster.bash = 0
	end
end



function OathBreaker(keys)
	local caster = keys.caster
	local ability = keys.ability
	if caster.bash ~= nil and caster.bash <= 100 then
		caster.bash = caster.bash + math.floor(ability:GetLevel()/2)
		if not caster:HasModifier("oathbreaker_charges") then
			ability:ApplyDataDrivenModifier(caster,caster,"oathbreaker_charges",{})
		end
		caster:SetModifierStackCount("oathbreaker_charges", ability, caster.bash)
	end
	ApplyDamage({victim = keys.target, attacker = caster, damage = ability:GetTalentSpecialValueFor("bonus_damage"), damage_type = ability:GetAbilityDamageType(), ability = ability})
end

function OathKeeper(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifier = "modifier_oathkeeper_block"
	if keys.damage < 25 then return end
	if caster.hit ~= nil then
		caster.hit = caster.hit + 1
		local proc_hit = ability:GetTalentSpecialValueFor("hit_proc")
		if caster.hit > proc_hit then
			ability:ApplyDataDrivenModifier(caster,caster,modifier,{})
			caster.hitcharge = caster.hitcharge + 1
			caster.hit = 0
		end
		if caster.hitcharge <= 75 then
			if not caster:HasModifier("oathkeeper_charges") then
				ability:ApplyDataDrivenModifier(caster,caster,"oathkeeper_charges",{})
			end
			caster:SetModifierStackCount("oathkeeper_charges", ability, caster.hitcharge)
		end
	else
		caster.hit = 0
	end
end

function SlardarRushTaunt( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local current_abilityindex = caster:GetAbilityByIndex(2)
	local current_ability = current_abilityindex:GetAbilityName()

	if current_ability == "slardar_oathkeeper" then
		-- Clear the force attack target
		target:SetForceAttackTarget(nil)

		-- Give the attack order if the caster is alive
		-- otherwise forces the target to sit and do nothing
		if caster:IsAlive() then
			local order = 
			{
				UnitIndex = target:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = caster:entindex()
			}

			ExecuteOrderFromTable(order)
		else
			target:Stop()
		end

		-- Set the force attack target to be the caster
		target:SetForceAttackTarget(caster)
		if not target:HasModifier("modifier_slardar_taunt_oathkeeper") then
			ability:ApplyDataDrivenModifier(caster,target,"modifier_slardar_taunt_oathkeeper",{})
			caster.threat = caster.threat + ability:GetLevel()
		end
	else
		if not target:HasModifier("modifier_slardar_taunt_oathbreaker") then
			ability:ApplyDataDrivenModifier(caster,target,"modifier_slardar_taunt_oathbreaker",{})
		end
	end
end

function SlardarRushBash(keys)
		local caster = keys.caster
		local ability = caster:GetAbilityByIndex(2)
		caster.bash = caster.bash + 5
		caster:RemoveModifierByName("oathbreaker_charges")
		if not caster:HasModifier("oathbreaker_charges") then
			ability:ApplyDataDrivenModifier(caster,caster,"oathbreaker_charges",{})
		end
		caster:SetModifierStackCount("oathbreaker_charges", ability, caster.bash)
end

function SlardarRushBlock(keys)
		local caster = keys.caster
		local ability = caster:GetAbilityByIndex(2)
		caster:RemoveModifierByName("modifier_oathkeeper_block")
		ability:ApplyDataDrivenModifier(caster,caster,"modifier_oathkeeper_block",{})
end
-- Clears the force attack target upon expiration
function SlardarRushTauntEnd( keys )
	local target = keys.target
	local newOrder = {
 		UnitIndex = target:entindex(), 
 		OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
 	}
 
	ExecuteOrderFromTable(newOrder)
	target:SetForceAttackTarget(nil)
end

function SlardarSlithereenReprisal(keys)
	local caster = keys.caster
	local ability = keys.ability
	local current_abilityindex = caster:GetAbilityByIndex(2)
	local current_ability = current_abilityindex:GetAbilityName()
	caster.spread = 0
	
	if current_ability == "slardar_oathbreaker" then
		ability:ApplyDataDrivenModifier(caster,caster,"oathbreaker_ult",{})
	else
		ability:ApplyDataDrivenModifier(caster,caster,"oathkeeper_ult",{})
		caster.threat = caster.threat + 10 * ability:GetLevel()
	end
end

function SlardarSlithereenReprisalFX(keys)
	local caster = keys.caster
	local ability = keys.ability
	particle_splash = ParticleManager:CreateParticle("particles/units/heroes/hero_slardar/slardar_loadout_water.vpcf", PATTACH_ABSORIGIN, keys.caster)
		ParticleManager:SetParticleControl(particle_splash, 0, GetGroundPosition(caster:GetAbsOrigin(), caster))
		ParticleManager:SetParticleControl(particle_splash, 1, Vector(caster.spread,caster.spread,caster.spread))
	particle_splash2 = ParticleManager:CreateParticle("particles/units/heroes/hero_slardar/slardar_loadout_water.vpcf", PATTACH_ABSORIGIN, keys.caster)
		ParticleManager:SetParticleControl(particle_splash2, 0, GetGroundPosition(caster:GetAbsOrigin(), caster))
		ParticleManager:SetParticleControl(particle_splash2, 1, Vector(caster.spread/2,caster.spread/2,caster.spread/2))
	caster.spread = caster.spread + 100
end

function SlardarSlithereenReprisalKeeperFX(keys)
	local target = keys.target
	local ability = keys.ability
	particle_splash = ParticleManager:CreateParticle("particles/units/heroes/hero_slardar/slardar_loadout_water.vpcf", PATTACH_ABSORIGIN, keys.caster)
		ParticleManager:SetParticleControl(particle_splash, 0, GetGroundPosition(target:GetAbsOrigin(), caster))
		ParticleManager:SetParticleControl(particle_splash, 1, Vector(100,100,100))
end

function SlardarSlithereenReprisalBreaker(keys)
	local caster = keys.caster
	local duration = keys.duration
	local ability = keys.ability
	local used_charges = ability:GetTalentSpecialValueFor("max_charge_reduction")
	local nearbyUnits = FindUnitsInRadius(caster:GetTeam(),
                                  caster:GetAbsOrigin(),
                                  nil,
                                  1000,
                                  DOTA_UNIT_TARGET_TEAM_ENEMY,
                                  DOTA_UNIT_TARGET_ALL,
                                  DOTA_UNIT_TARGET_FLAG_NONE,
                                  FIND_ANY_ORDER,
                                  false)
	for _,unit in pairs(nearbyUnits) do
		local armor = unit:GetPhysicalArmorValue()
		ability:ApplyDataDrivenModifier(caster,unit,"oathbreaker_ult_reduction_base",{duration = duration})
		if caster.bash >= used_charges then
			ability:ApplyDataDrivenModifier(caster,unit,"oathbreaker_ult_reduction_charge",{duration = duration})
			unit:SetModifierStackCount("oathbreaker_ult_reduction_charge", ability, (armor*used_charges)/100)
			
		else
			ability:ApplyDataDrivenModifier(caster,unit,"oathbreaker_ult_reduction_charge",{duration = duration})
			unit:SetModifierStackCount("oathbreaker_ult_reduction_charge", ability, (armor*caster.bash)/100)
			
		end
	end
	if caster.bash >= used_charges then
		caster.bash = caster.bash - used_charges
		caster:SetModifierStackCount("oathbreaker_charges", ability, caster.bash)
	else
		caster.bash = 0
		caster:RemoveModifierByName("oathbreaker_charges")
	end
	caster:RemoveModifierByName("oathbreaker_ult")
end

function SlardarSlithereenReprisalKeeper(keys)
	local caster = keys.caster
	local duration = keys.duration
	local ability = keys.ability
	local nearbyUnits = FindUnitsInRadius(caster:GetTeam(),
                                  caster:GetAbsOrigin(),
                                  nil,
                                  1000,
                                  DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                  DOTA_UNIT_TARGET_ALL,
                                  DOTA_UNIT_TARGET_FLAG_NONE,
                                  FIND_ANY_ORDER,
                                  false)
	for _,unit in pairs(nearbyUnits) do
		ability:ApplyDataDrivenModifier(caster,unit,"oathkeeper_ult_reduction_base",{duration = duration})
		ability:ApplyDataDrivenModifier(caster,unit,"oathkeeper_ult_reduction_charge",{duration = duration})
		unit:SetModifierStackCount("oathkeeper_ult_reduction_charge", keys.ability, math.floor(caster.hitcharge/3))
	end		
	ability:ApplyDataDrivenModifier(caster,caster,"oathkeeper_ult_reduction_base",{duration = duration})
	ability:ApplyDataDrivenModifier(caster,caster,"oathkeeper_ult_reduction_charge",{duration = duration})
	caster:SetModifierStackCount("oathkeeper_ult_reduction_charge", keys.ability, math.floor(caster.hitcharge/3))	
	caster:RemoveModifierByName("oathkeeper_ult")
	caster.hitcharge = 0
	caster:RemoveModifierByName("oathkeeper_charges")
end


function SlardarSwapAbility(keys)
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel()
	local current_index = caster:GetAbilityByIndex(2)
	local current = current_index:GetAbilityName()
	local toswap = tostring(keys.abilityswap)
	caster:RemoveAbility(current)
	caster:AddAbility(toswap)
	caster:FindAbilityByName(toswap):SetLevel(ability_level)
	caster:FindAbilityByName(toswap):StartCooldown(5)
	if	caster:GetAbilityByIndex(2):GetAbilityName() == "slardar_oathkeeper" then
		caster:RemoveModifierByName("oathbreaker_charges")
		caster:RemoveModifierByName("modifier_bash_datadriven")
	elseif caster:GetAbilityByIndex(2):GetAbilityName() == "slardar_oathbreaker" then
		caster:RemoveModifierByName("oathkeeper_charges")
		caster:RemoveModifierByName("modifier_defend_datadriven")
	end
end
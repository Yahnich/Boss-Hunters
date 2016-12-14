function Berserking( keys )
	local caster = keys.caster
	if not caster:IsRealHero() then return end
	
	local threatgen = keys.ability:GetTalentSpecialValueFor("threat")
	local threat_tick = keys.ability:GetTalentSpecialValueFor("threat_tick")
	local threat = threatgen*threat_tick
	caster.threat = caster.threat + threat
	local player = PlayerResource:GetPlayer(caster:GetPlayerID())
	caster.lastHit = GameRules:GetGameTime()
	local event_data =
	{
		threat = caster.threat,
		lastHit = caster.lastHit,
		aggro = caster.aggro
	}
	CustomGameEventManager:Send_ServerToPlayer( player, "Update_threat", event_data )
	
	for _,hero in pairs ( Entities:FindAllByName( "npc_dota_hero*")) do
		if hero:IsRealHero() and hero ~= caster and hero.threat > caster.threat then
			hero.threat = hero.threat - threat
			local player = PlayerResource:GetPlayer(hero:GetPlayerID())
			hero.lastHit = GameRules:GetGameTime()
			PlayerResource:SortThreat()
			local event_data =
			{
				threat = hero.threat,
				lastHit = hero.lastHit,
				aggro = hero.aggro
			}
			CustomGameEventManager:Send_ServerToPlayer( player, "Update_threat", event_data )
		end
	end
end

function BerserkHeal(keys)
	local caster = keys.caster
	local ability = keys.ability
	local chance = ability:GetTalentSpecialValueFor("heal_chance")
	local cooldown = ability:GetTalentSpecialValueFor("internal_cooldown")
	if not ability.lastproc then ability.lastproc = 0 end
	if math.random(100) < chance and ability.lastproc + cooldown < GameRules:GetGameTime() and caster:GetHealth() <= caster:GetMaxHealth()*0.75 then
		local amount = ability:GetTalentSpecialValueFor("heal_amount")/100
		local heal = caster:GetMaxHealth() * amount
		caster:Heal(heal, caster)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, caster, heal, nil)
		ability.lastproc = GameRules:GetGameTime()
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_internal_cooldown", {duration = cooldown})
	end
end

LinkLuaModifier( "modifier_movespeed_cap", "libraries/modifiers/modifier_movespeed_cap.lua" ,LUA_MODIFIER_MOTION_NONE )

function ApplyBuff(keys)
	local caster = keys.caster
	local target = keys.target
	local caster_origin = caster:GetAbsOrigin()
	
	local ability = keys.ability
	local duration = ability:GetTalentSpecialValueFor("buff_duration")
	
	-- Checks if the ability is off cooldown and if the caster is attacking a target
	if target then
		local target_origin = target:GetAbsOrigin()
		local distance = math.sqrt((caster_origin.x - target_origin.x)^2 + (caster_origin.y - target_origin.y)^2)
		ability.target = target
		-- Checks if the caster is in range of the target
		local speed_effect = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_lancer/phantom_lancer_dying.vpcf", PATTACH_ABSORIGIN  , keys.caster)
		ParticleManager:SetParticleControl(speed_effect, 0, caster_origin)
		ParticleManager:SetParticleControl(speed_effect, 2, caster_origin)
		ParticleManager:SetParticleControl(speed_effect, 5, caster_origin)
		-- Removes the 522 move speed cap
		caster:AddNewModifier(caster, nil, "modifier_movespeed_cap", { duration = duration })
		-- Apply the speed buff
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_speed_buff", {})
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_check_distance", {})
		
		caster:MoveToTargetToAttack(target)
	end
end

--[[Author: YOLOSPAGHETTI
	Date: February 16, 2016
	Checks if the caster is in range of the target]]
function DistanceCheck(keys)
	local caster = keys.caster
	local caster_origin = caster:GetAbsOrigin()
	
	local ability = keys.ability
	local target = ability.target
	local min_distance = caster:GetAttackRange()
	min_distance = min_distance + target:GetCollisionPadding() + target:GetHullRadius() + caster:GetCollisionPadding() + caster:GetHullRadius()
	local duration = ability:GetTalentSpecialValueFor("heal_duration")
	local stun = ability:GetTalentSpecialValueFor("stun_duration")
	
	-- Checks if Dragon Knight is in 'stun' range
	local target_origin = ability.target:GetAbsOrigin()
	local distance = math.sqrt((caster_origin.x - target_origin.x)^2 + (caster_origin.y - target_origin.y)^2)
	-- Checks if the caster is in range of the target
	print(distance,min_distance)
	if distance <= min_distance then
		caster:RemoveModifierByName("modifier_check_distance")
		caster:RemoveModifierByName("modifier_speed_buff")
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_intervene", {duration = duration})
		if caster:GetTeam() ~= target:GetTeam() then
			ExecuteOrderFromTable({
				UnitIndex = caster:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
				TargetIndex = target:entindex()
			})
			print("stun")
			ability:ApplyDataDrivenModifier(caster, target, "modifier_stunned", {duration = stun})
			ability:ApplyDataDrivenModifier(caster, target, "modifier_stun", {duration = stun})
			EmitSoundOn("Hero_DragonKnight.DragonTail.Target",target)
			ApplyDamage({victim = target, 
						attacker = caster, 
						damage = ability:GetAbilityDamage(), 
						damage_type = ability:GetAbilityDamageType(), 
						ability = ability})
		else
			target.threat = 0
		end
	end
end

--[[Author: YOLOSPAGHETTI
	Date: February 16, 2016
	Removes the speed buff if the attack command is canceled]]
function RemoveBuff(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	
	if target == nil or target ~= ability.target then
		caster:RemoveModifierByName("modifier_speed_buff")
		caster:RemoveModifierByName("modifier_movespeed_cap")
	end
end

function InterveneStacks(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:RemoveModifierByName("modifier_intervene_stacks")
	local healthregen = caster:GetHealthRegen()
	local bonus = ability:GetTalentSpecialValueFor("heal_bonus")
	local stacks = healthregen * ((bonus - 100)/100) -- 200% means doubling; so remove original health regen percent
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_intervene_stacks", {})
	keys.caster:SetModifierStackCount("modifier_intervene_stacks", caster, healthregen)
end
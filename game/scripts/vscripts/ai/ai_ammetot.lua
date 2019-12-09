--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	
	thisEntity.see = thisEntity:FindAbilityByName("boss_ammetot_see_all")
	thisEntity.gatekeeper = thisEntity:FindAbilityByName("boss_ammetot_gatekeeper")
	thisEntity.unbound = thisEntity:FindAbilityByName("boss_ammetot_unbound")
	thisEntity.fate = thisEntity:FindAbilityByName("boss_ammetot_fate_acceptance")
	
	thisEntity.warden = thisEntity:FindAbilityByName("boss_ammetot_restless_warden")
	thisEntity.illusion = thisEntity:FindAbilityByName("boss_ammetot_illusion_of_inevitability")
	thisEntity.prisoner = thisEntity:FindAbilityByName("boss_ammetot_willing_prisoner")
	thisEntity.death = thisEntity:FindAbilityByName("boss_ammetot_death_is_lonely")

	AITimers:CreateTimer(0.1, function()
		if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
			thisEntity.see:SetLevel(1)
			thisEntity.gatekeeper:SetLevel(1)
			thisEntity.unbound:SetLevel(1)
			thisEntity.fate:SetLevel(1)
			
			thisEntity.warden:SetLevel(1)
			thisEntity.illusion:SetLevel(1)
			thisEntity.prisoner:SetLevel(1)
			thisEntity.spore:SetLevel(1)
		else
			thisEntity.see:SetLevel(2)
			thisEntity.gatekeeper:SetLevel(2)
			thisEntity.unbound:SetLevel(2)
			thisEntity.fate:SetLevel(2)
			
			thisEntity.warden:SetLevel(2)
			thisEntity.illusion:SetLevel(2)
			thisEntity.prisoner:SetLevel(2)
			thisEntity.death:SetLevel(2)
		end
	end)
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		local target = AICore:GetHighestPriorityTarget(thisEntity)
		if thisEntity.warden:IsFullyCastable() and ( thisEntity:GetAttackTarget() or AICore:BeingAttacked( thisEntity ) > 0 ) then
			return CastWarden()
		end
		if thisEntity.illusion:IsFullyCastable() and ( AICore:RandomEnemyHeroInRange( thisEntity, thisEntity.illusion:GetTrueCastRange() ) or target ) then
			return CastIllusion( AICore:RandomEnemyHeroInRange( thisEntity, thisEntity.illusion:GetTrueCastRange() ) or target )
		end
		if thisEntity.prisoner:IsFullyCastable() and ( AICore:NearestEnemyHeroInRange( thisEntity, thisEntity.prisoner:GetTrueCastRange() ) or target ) then
			return CastPrisoner( AICore:NearestEnemyHeroInRange( thisEntity, thisEntity.prisoner:GetTrueCastRange() ) or target )
		end
		if thisEntity.death:IsFullyCastable() and ( AICore:RandomEnemyHeroInRange( thisEntity, thisEntity.death:GetTrueCastRange() ) or target ) then
			return CastDeath( AICore:RandomEnemyHeroInRange( thisEntity, thisEntity.death:GetTrueCastRange() ) or target )
		end
		return AICore:AttackHighestPriority( thisEntity )
	else 
		return AI_THINK_RATE 
	end
end

function CastWarden()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.warden:entindex()
	})
	return thisEntity.warden:GetCastPoint() + 0.1
end

function CastIllusion(target)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = thisEntity.illusion:entindex()
	})
	return thisEntity.illusion:GetCastPoint() + 0.1
end

function CastPrisoner(target)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = thisEntity.prisoner:entindex()
	})
	return thisEntity.prisoner:GetCastPoint() + 0.1
end

function CastDeath(target)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = target:entindex(),
		AbilityIndex = thisEntity.death:entindex()
	})
	return thisEntity.death:GetCastPoint() + 0.1
end
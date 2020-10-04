if IsClient() then return end

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.wild = thisEntity:FindAbilityByName("boss_valgraduth_breath_of_the_wild")
	thisEntity.entangle = thisEntity:FindAbilityByName("boss_valgraduth_entangling_grip")
	
	thisEntity.protect = thisEntity:FindAbilityByName("boss_valgraduth_forests_protection")
	thisEntity.grip = thisEntity:FindAbilityByName("boss_valgraduth_roots_grip")
	thisEntity.spore = thisEntity:FindAbilityByName("boss_valgraduth_bomb_spores")

	AITimers:CreateTimer(0.1, function()
		if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
			thisEntity.wild:SetLevel(1)
			thisEntity.entangle:SetLevel(1)
			
			thisEntity.protect:SetLevel(1)
			thisEntity.grip:SetLevel(1)
			thisEntity.spore:SetLevel(1)
		else
			thisEntity.wild:SetLevel(2)
			thisEntity.entangle:SetLevel(2)
			
			thisEntity.protect:SetLevel(2)
			thisEntity.grip:SetLevel(2)
			thisEntity.spore:SetLevel(2)
		end
	end)
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		local target = AICore:GetHighestPriorityTarget(thisEntity)
		if thisEntity.protect:IsFullyCastable() then
			return CastProtect()
		end
		if thisEntity.grip:IsFullyCastable() and ( thisEntity:HasModifier("modifier_boss_valgraduth_bomb_spores_bomb") or RollPercentage(20) or AICore:RandomEnemyHeroInRange( thisEntity, 900 , true ) ) then
			return CastGrip()
		end
		if thisEntity.spore:IsFullyCastable() then
			return CastSpore()
		end
		return AICore:AttackHighestPriority( thisEntity )
	else 
		return AI_THINK_RATE 
	end
end

function CastProtect()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.protect:entindex()
	})
	return thisEntity.protect:GetCastPoint() + 0.1
end

function CastGrip()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.grip:entindex()
	})
	return thisEntity.grip:GetCastPoint() + 0.1
end

function CastSpore()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.spore:entindex()
	})
	return thisEntity.spore:GetCastPoint() + 0.1
end
if IsServer() then
	require( "ai/ai_core" )
	
	AI_STATE_CLOSE_COMBAT = 1
	AI_STATE_CHASING = 2
	
	function Spawn( entityKeyValues )
		thisEntity:SetContextThink( "AIThinker", AIThink, 0.25 )
		thisEntity.leap = thisEntity:FindAbilityByName("boss1b_leap")
		thisEntity.pin = thisEntity:FindAbilityByName("boss1b_spear_pin")
		thisEntity.pierce = thisEntity:FindAbilityByName("boss1b_spear_pierce")
		if  math.floor(GameRules.gameDifficulty + 0.5) > 2 then
			thisEntity.leap:SetLevel(2)
			thisEntity.pin:SetLevel(2)
			thisEntity.pierce:SetLevel(2)
			
			thisEntity:SetBaseMaxHealth(thisEntity:GetMaxHealth()*1.5)
			thisEntity:SetMaxHealth(thisEntity:GetMaxHealth()*1.5)
			thisEntity:SetHealth(thisEntity:GetMaxHealth())
			
			 thisEntity:SetAverageBaseDamage(thisEntity:GetAverageBaseDamage()*1.2, 30)
		else
			thisEntity.leap:SetLevel(1)
			thisEntity.pin:SetLevel(1)
			thisEntity.pierce:SetLevel(1)
		end
	end


	function AIThink()
		if not thisEntity:IsDominated() and not thisEntity:IsCommandRestricted() then
			EvaluateBehavior(thisEntity)
			if thisEntity.AIstate == AI_STATE_CLOSE_COMBAT then
				if thisEntity:GetAIBehavior() == AI_BEHAVIOR_AGGRESSIVE then -- uses all abilities without concern of options
					
				elseif thisEntity.AIbehavior == AI_BEHAVIOR_CAUTIOUS then -- uses abilities to get in and out
					
				elseif thisEntity.AIbehavior == AI_BEHAVIOR_SAFE then -- tries to use mobility and invis to focus a target down and runs if it gets attacked by others, unless if it has no other choice
					
			elseif thisEntity.AIstate == AI_STATE_CHASING then
				
			end
			AICore:AttackHighestPriority( thisEntity )
			return 0.25
		else return 0.25 end
	end
	
	function EvaluateBehavior(entity)
		if AICore:IsNearEnemyUnit(entity, entity:GetAttackRange() + entity:GetIdealSpeed() * 0.8 ) then
			entity.AIstate = AI_STATE_CLOSE_COMBAT
		else
			entity.AIstate = AI_STATE_CHASING
		end
		end
	end
end
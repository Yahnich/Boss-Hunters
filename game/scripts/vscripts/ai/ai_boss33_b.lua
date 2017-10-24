if IsServer() then
	require( "ai/ai_core" )
	function Spawn( entityKeyValues )
		thisEntity:SetContextThink( "AIThinker", AIThink, 0.25 )
		thisEntity.raze1 = thisEntity:FindAbilityByName("boss33b_shadowrazeN")
		thisEntity.raze2 = thisEntity:FindAbilityByName("boss33b_shadowrazeM")
		thisEntity.raze3 = thisEntity:FindAbilityByName("boss33b_shadowrazeF")
		thisEntity.shield = thisEntity:FindAbilityByName("boss33b_protective_shield")
		Timers:CreateTimer(function()
			if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
				thisEntity.raze1:SetLevel(1)
				thisEntity.raze1:SetLevel(1)
				thisEntity.raze1:SetLevel(1)
				thisEntity.raze1:SetLevel(1)
			else
				thisEntity.raze1:SetLevel(2)
				thisEntity.raze1:SetLevel(2)
				thisEntity.raze1:SetLevel(2)
				thisEntity.raze1:SetLevel(2)
				
				thisEntity:SetBaseMaxHealth(thisEntity:GetBaseMaxHealth()*1.5)
				thisEntity:SetMaxHealth(thisEntity:GetMaxHealth()*1.5)
				thisEntity:SetHealth(thisEntity:GetMaxHealth())
			end
		end)
	end


	function AIThink()
		if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
			-- local target = AICore:GetHighestPriorityTarget(thisEntity)
			-- AICore:AttackHighestPriority( thisEntity )
			return 0.25
		else return 0.25 end
	end
end
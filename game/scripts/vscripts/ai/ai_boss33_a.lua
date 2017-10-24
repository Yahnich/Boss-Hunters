if IsServer() then
	require( "ai/ai_core" )
	function Spawn( entityKeyValues )
		thisEntity:SetContextThink( "AIThinker", AIThink, 0.25 )
		thisEntity.poison = thisEntity:FindAbilityByName("boss33a_devitalize")
		thisEntity.orb = thisEntity:FindAbilityByName("boss33a_dark_orb")
		thisEntity.ward = thisEntity:FindAbilityByName("boss33a_protective_ward")
		Timers:CreateTimer(0.1, function()
			if  math.floor(GameRules.gameDifficulty + 0.5) < 2 then 
				thisEntity.poison:SetLevel(1)
				thisEntity.orb:SetLevel(1)
				thisEntity.ward:SetLevel(1)
			else
				thisEntity.poison:SetLevel(2)
				thisEntity.orb:SetLevel(2)
				thisEntity.ward:SetLevel(2)
				
				thisEntity:SetBaseMaxHealth(thisEntity:GetMaxHealth()*1.5)
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
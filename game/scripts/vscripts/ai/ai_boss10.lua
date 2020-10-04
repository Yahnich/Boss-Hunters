if IsClient() then return end

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	AITimers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.fire = thisEntity:FindAbilityByName("boss_roshan_flamethrower")
	thisEntity.crush = thisEntity:FindAbilityByName("boss_roshan_crushing_clap")
	thisEntity.boom = thisEntity:FindAbilityByName("boss_roshan_sonic_boom")
	
	thisEntity.blows = thisEntity:FindAbilityByName("boss_roshan_heavy_blows")
	thisEntity.bane = thisEntity:FindAbilityByName("boss_roshan_heros_bane")
	AITimers:CreateTimer(0.1, function()
		thisEntity.fire:SetLevel(GameRules:GetGameDifficulty() / 2)
		thisEntity.crush:SetLevel(GameRules:GetGameDifficulty() / 2)
		thisEntity.boom:SetLevel(GameRules:GetGameDifficulty() / 2)
		
		thisEntity.blows:SetLevel(GameRules:GetGameDifficulty() / 2)
		thisEntity.bane:SetLevel(GameRules:GetGameDifficulty() / 2)
	end)
	thisEntity.idle = GameRules:GetGameTime()
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
		if not thisEntity:IsChanneling() then
			if thisEntity.crush and thisEntity.crush:IsFullyCastable() and RollPercentage( 50 ) then
				if AICore:TotalEnemyHeroesInRange( thisEntity, thisEntity.crush:GetTrueCastRange() ) > 0 then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.crush:entindex()
					})
					return thisEntity.crush:GetCastPoint()
				end
			end
			if thisEntity.fire:IsFullyCastable() then
				target = AICore:NearestDisabledEnemyHeroInRange( thisEntity, thisEntity.fire:GetTrueCastRange(), false )
				if target then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = target:GetOrigin(),
						AbilityIndex = thisEntity.fire:entindex()
					})
					thisEntity.idle = GameRules:GetGameTime()
					return thisEntity.fire:GetCastPoint() + thisEntity.fire:GetChannelTime()
				end
			end
			print( AICore:BeingAttacked( thisEntity ) )
			if thisEntity.boom and thisEntity.boom:IsFullyCastable() and AICore:BeingAttacked( thisEntity ) >= 1 and RollPercentage( math.min( 100, 10 + 15 * AICore:BeingAttacked( thisEntity ) ) ) then
				local enemies = AICore:BeingAttackedBy( thisEntity )
				local enemy = GetRandomInTable( enemies )
				if enemy then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
						Position = enemy:GetOrigin(),
						AbilityIndex = thisEntity.boom:entindex()
					})
					return thisEntity.boom:GetCastPoint() + thisEntity.boom:GetChannelTime()
				end
			end
			-- FORCE CAST AFTER SET DURATION --
			if thisEntity.idle + thisEntity.fire:GetEffectiveCooldown(-1) + 5 < GameRules:GetGameTime() and thisEntity.fire:IsFullyCastable() then
				target = AICore:HighestThreatHeroInRange(thisEntity, 1050, 0, true)
				if target then
					ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
							Position = target:GetOrigin(),
							AbilityIndex = thisEntity.fire:entindex()
					})
					thisEntity.idle = GameRules:GetGameTime()
					return thisEntity.fire:GetCastPoint() + thisEntity.fire:GetChannelTime()
				end
			end
			return AICore:AttackHighestPriority( thisEntity )
		else
			return 0.5
		end
	else return AI_THINK_RATE end
end
--[[
Broodking AI
]]

if IsServer() then
	require( "ai/ai_core" )
	function Spawn( thisEntityKeyValues )
		AITimers:CreateTimer(function()
			if thisEntity and not thisEntity:IsNull() then
				return AIThink(thisEntity)
			end
		end)
		thisEntity.mark = thisEntity:FindAbilityByName("boss27_kill_them")
		thisEntity.destroy = thisEntity:FindAbilityByName("boss27_destroy")
		thisEntity.protect = thisEntity:FindAbilityByName("boss27_protect_me")
		thisEntity.bigbear = thisEntity:FindAbilityByName("boss27_ursa_giant")
		thisEntity.smallbear = thisEntity:FindAbilityByName("boss27_ursa_warrior")
		
		thisEntity.bigBearsTable = thisEntity.bigBearsTable or {}
		thisEntity.smallBearsTable = thisEntity.smallBearsTable or {}
		
		thisEntity.GetBigBears = function(thisEntity) return thisEntity.bigBearsTable or {} end
		thisEntity.GetSmallBears = function(thisEntity) return thisEntity.smallBearsTable or {} end
		
		thisEntity.GetBigBearCount = function(thisEntity) return #thisEntity.bigBearsTable or 0 end
		thisEntity.GetSmallBearCount = function(thisEntity) return #thisEntity.smallBearsTable or 0 end
		
		thisEntity.GetMaxBigBearCount = function(thisEntity) return math.ceil(#HeroList:GetActiveHeroes() / 2) end
		thisEntity.GetMaxSmallBearCount = function(thisEntity) return math.ceil(#HeroList:GetActiveHeroes() * 2) end
		
		thisEntity.GetTotalBearCount = function(thisEntity) return thisEntity:GetBigBearCount() + thisEntity:GetSmallBearCount() end
		thisEntity.GetMaxTotalBearCount = function(thisEntity) return thisEntity:GetMaxBigBearCount() + thisEntity:GetMaxSmallBearCount() end
		
		AITimers:CreateTimer(1, function()
			for i = 30, 1, -1 do
				if thisEntity.bigBearsTable[ì] and ( thisEntity.bigBearsTable[ì]:IsNull() or not thisEntity.bigBearsTable[ì]:IsAlive() ) then
					table.remove( thisEntity.bigBearsTable, i )
				end
				if thisEntity.smallBearsTable[ì] and ( thisEntity.smallBearsTable[ì]:IsNull() or not thisEntity.smallBearsTable[ì]:IsAlive() ) then
					table.remove( thisEntity.smallBearsTable, i )
				end
			end
			return 1
		end)
		
		AITimers:CreateTimer(0.1, function()
			if  math.floor(GameRules.gameDifficulty + 0.5) <= 2 then
				thisEntity.mark:SetLevel(1)
				thisEntity.destroy:SetLevel(1)
				thisEntity.protect:SetLevel(1)
				thisEntity.bigbear:SetLevel(1)
				thisEntity.smallbear:SetLevel(1)
			else
				thisEntity.mark:SetLevel(2)
				thisEntity.destroy:SetLevel(2)
				thisEntity.protect:SetLevel(2)
				thisEntity.bigbear:SetLevel(2)
				thisEntity.smallbear:SetLevel(2)
			end
		end)
	end


	function AIThink(thisEntity)
		if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
			if AICore:BeingAttacked( thisEntity ) > 0 then
				local nearest = AICore:NearestEnemyHeroInRange( thisEntity, thisEntity:GetIdealSpeed() * 1.5 + thisEntity:GetAttackRange(), true )
				if thisEntity:GetTotalBearCount() == 0 then
					if thisEntity.bigbear:IsFullyCastable() then
						return SummonBearGiant(thisEntity)
					end
					if thisEntity.smallbear:IsFullyCastable() then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
							AbilityIndex = thisEntity.smallbear:entindex()
						})
						return thisEntity.smallbear:GetCastPoint() + 0.1
					end
					if nearest then
						if thisEntity.mark:IsFullyCastable() and RollPercentage(45) then
							local target = thisEntity:GetTauntTarget() or nearest
							if target then
								ExecuteOrderFromTable({
									UnitIndex = thisEntity:entindex(),
									OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
									TargetIndex = target:entindex(),
									AbilityIndex = thisEntity.mark:entindex()
								})
								return thisEntity.mark:GetCastPoint() + 0.1
							end
						end
						return AICore:AttackHighestPriority( thisEntity )
					end
				else
					if thisEntity.protect:IsFullyCastable() and RollPercentage(65) then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
							AbilityIndex = thisEntity.protect:entindex()
						})
						return thisEntity.protect:GetCastPoint() + 0.1
					end
					if thisEntity.mark:IsFullyCastable() and RollPercentage(60) then
						local target = thisEntity:GetTauntTarget() or AICore:RandomEnemyHeroInRange( thisEntity, 8000 , true)
						if target then
							ExecuteOrderFromTable({
								UnitIndex = thisEntity:entindex(),
								OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
								TargetIndex = target:entindex(),
								AbilityIndex = thisEntity.mark:entindex()
							})
							return thisEntity.mark:GetCastPoint() + 0.1
						end
					end
					if thisEntity.destroy:IsFullyCastable() and RollPercentage(80) then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
							AbilityIndex = thisEntity.destroy:entindex()
						})
						return thisEntity.destroy:GetCastPoint() + 0.1
					end
					if thisEntity.bigbear:IsFullyCastable() and thisEntity:GetBigBearCount() <= thisEntity:GetMaxBigBearCount() and RollPercentage( 50 / math.min(thisEntity:GetBigBearCount(), 1) ) then
						return SummonBearGiant(thisEntity)
					end
					if thisEntity.smallbear:IsFullyCastable() and thisEntity:GetSmallBearCount() <= thisEntity:GetMaxSmallBearCount()  and RollPercentage(50 / math.min(thisEntity:GetSmallBearCount(), 1)) then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
							AbilityIndex = thisEntity.smallbear:entindex()
						})
						return thisEntity.smallbear:GetCastPoint() + 0.1

					end
				end
				return AICore:AttackHighestPriority( thisEntity )
			else
				if thisEntity.bigbear:IsFullyCastable() and thisEntity:GetBigBearCount() <= thisEntity:GetMaxBigBearCount() then
					return SummonBearGiant(thisEntity)
				end
				if thisEntity.smallbear:IsFullyCastable() and thisEntity:GetSmallBearCount() <= thisEntity:GetMaxSmallBearCount() then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.smallbear:entindex()
					})
					return thisEntity.smallbear:GetCastPoint() + 0.1
				end
				if thisEntity.mark:IsFullyCastable() and RollPercentage(35) then
					local target = thisEntity:GetTauntTarget() or AICore:RandomEnemyHeroInRange( thisEntity, 8000 , true)
					if target then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
							TargetIndex = target:entindex(),
							AbilityIndex = thisEntity.mark:entindex()
						})
						return thisEntity.mark:GetCastPoint() + 0.1
					end
				end				
				if thisEntity.destroy:IsFullyCastable() and ( thisEntity:GetTotalBearCount() >= math.floor( GetMaxTotalBearCount / 2 ) or RollPercentage(15) ) then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.destroy:entindex()
					})
					return thisEntity.destroy:GetCastPoint() + 0.1
				end
				AICore:BeAHugeCoward( thisEntity, 900 )
				return AI_THINK_RATE
			end
			return AI_THINK_RATE
		else return AI_THINK_RATE end
		return AI_THINK_RATE
	end
end

function SummonBearGiant(thisEntity)
	print( thisEntity.bigbear:GetCastPoint() )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.bigbear:entindex()
	})
	return thisEntity.bigbear:GetCastPoint() + 0.1
end
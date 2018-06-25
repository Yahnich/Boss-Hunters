--[[
Broodking AI
]]

if IsServer() then
	require( "ai/ai_core" )
	function Spawn( thisEntityKeyValues )
		Timers:CreateTimer(function()
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
		
		thisEntity.GetBigBears = function(self) return self.bigBearsTable or {} end
		thisEntity.GetSmallBears = function(self) return self.smallBearsTable or {} end
		
		thisEntity.GetBigBearCount = function(self) return #self.bigBearsTable or 0 end
		thisEntity.GetSmallBearCount = function(self) return #self.smallBearsTable or 0 end
		
		thisEntity.GetTotalBearCount = function(self) return self:GetBigBearCount() + self:GetSmallBearCount() end
		
		Timers:CreateTimer(1, function()
			for id, bear in pairs( thisEntity.bigBearsTable ) do
				if bear:IsNull() or not bear:IsAlive() then
					table.remove(thisEntity.bigBearsTable, id)
				end
			end
			for id, bear in pairs( thisEntity.smallBearsTable ) do
				if bear:IsNull() or not bear:IsAlive() then
					table.remove(thisEntity.smallBearsTable, id)
				end
			end
			return 1
		end)
		
		Timers:CreateTimer(0.1, function()
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
				if thisEntity:GetTotalBearCount() == 0 then
					if thisEntity.bigbear:IsFullyCastable() then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
							AbilityIndex = thisEntity.bigbear:entindex()
						})
						return AI_THINK_RATE
					end
					if thisEntity.smallbear:IsFullyCastable() then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
							AbilityIndex = thisEntity.smallbear:entindex()
						})
						return AI_THINK_RATE
					end
					if thisEntity.mark:IsFullyCastable() and RollPercentage(45) then
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
					if thisEntity.protect:IsFullyCastable() and thisEntity:GetTotalBearCount() < 4 and RollPercentage(20) then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
							AbilityIndex = thisEntity.protect:entindex()
						})
						return thisEntity.protect:GetCastPoint() + 0.1
					end
					if thisEntity.destroy:IsFullyCastable() and thisEntity:GetTotalBearCount() > 6 and RollPercentage(20) then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
							AbilityIndex = thisEntity.destroy:entindex()
						})
						return thisEntity.destroy:GetCastPoint() + 0.1
					end
				else
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
					if thisEntity.destroy:IsFullyCastable() and thisEntity:GetTotalBearCount() > 6 and RollPercentage(80) then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
							AbilityIndex = thisEntity.destroy:entindex()
						})
						return thisEntity.destroy:GetCastPoint() + 0.1
					end
					if thisEntity.protect:IsFullyCastable() and thisEntity:GetTotalBearCount() < 4 and RollPercentage(20) then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
							AbilityIndex = thisEntity.protect:entindex()
						})
						return thisEntity.protect:GetCastPoint() + 0.1
					end
					if thisEntity.bigbear:IsFullyCastable() and thisEntity:GetBigBearCount() <= 3 and RollPercentage(50 / thisEntity:GetBigBearCount()) then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
							AbilityIndex = thisEntity.bigbear:entindex()
						})
						return AI_THINK_RATE
					end
					if thisEntity.smallbear:IsFullyCastable() and thisEntity:GetSmallBearCount() <= 6  and RollPercentage(50 / thisEntity:GetSmallBearCount()) then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
							AbilityIndex = thisEntity.smallbear:entindex()
						})
						return AI_THINK_RATE

					end
				end
				AICore:AttackHighestPriority( thisEntity )
				return AI_THINK_RATE
			else
				if thisEntity:GetTotalBearCount() == 0 and thisEntity:GetTotalBearCount() < 9 then
					if thisEntity.bigbear:IsFullyCastable() and thisEntity:GetBigBearCount() <= 3 then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
							AbilityIndex = thisEntity.bigbear:entindex()
						})
						return AI_THINK_RATE
					end
					if thisEntity.smallbear:IsFullyCastable() and thisEntity:GetSmallBearCount() <= 6 then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
							AbilityIndex = thisEntity.smallbear:entindex()
						})
						return AI_THINK_RATE
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
					if thisEntity.destroy:IsFullyCastable() and (thisEntity:GetTotalBearCount() > 5 or RollPercentage(35)) then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
							AbilityIndex = thisEntity.destroy:entindex()
						})
						return thisEntity.destroy:GetCastPoint() + 0.1
					end
				else
					if thisEntity.mark:IsFullyCastable() and RollPercentage(45) then
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
					if thisEntity.destroy:IsFullyCastable() and (thisEntity:GetTotalBearCount() > 6 or RollPercentage(20)) then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
							AbilityIndex = thisEntity.destroy:entindex()
						})
						return thisEntity.destroy:GetCastPoint() + 0.1
					end
					if thisEntity.bigbear:IsFullyCastable() and thisEntity:GetBigBearCount() <= 5 and RollPercentage(100 / thisEntity:GetBigBearCount()) then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
							AbilityIndex = thisEntity.bigbear:entindex()
						})
						return AI_THINK_RATE
					end
					if thisEntity.smallbear:IsFullyCastable() and thisEntity:GetSmallBearCount() <= 10  and RollPercentage(100 / thisEntity:GetSmallBearCount()) then
						ExecuteOrderFromTable({
							UnitIndex = thisEntity:entindex(),
							OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
							AbilityIndex = thisEntity.smallbear:entindex()
						})
						return AI_THINK_RATE
					end
				end
				AICore:BeAHugeCoward( thisEntity, 900 )
				return AI_THINK_RATE
			end
			return AI_THINK_RATE
		else return AI_THINK_RATE end
		return AI_THINK_RATE
	end
end
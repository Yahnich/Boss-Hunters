--[[
Broodking AI
]]

require( "ai/ai_core" )

function Spawn( entityKeyValues )
	Timers:CreateTimer(function()
		if thisEntity and not thisEntity:IsNull() then
			return AIThink(thisEntity)
		end
	end)
	thisEntity.rewind = thisEntity:FindAbilityByName("boss_rewind")
	thisEntity.juncture = thisEntity:FindAbilityByName("boss_juncture")
	thisEntity.overtime = thisEntity:FindAbilityByName("boss_overtime")
	thisEntity.yesteryear = thisEntity:FindAbilityByName("boss_yesteryear")
	if  math.floor(GameRules.gameDifficulty + 0.5) > 2 then 
		thisEntity.rewind:SetLevel(3)
		thisEntity.juncture:SetLevel(3)
		thisEntity.overtime:SetLevel(3)
		thisEntity.yesteryear:SetLevel(3)
	elseif  math.floor(GameRules.gameDifficulty + 0.5) == 2  then
		thisEntity.rewind:SetLevel(2)
		thisEntity.juncture:SetLevel(2)
		thisEntity.overtime:SetLevel(2)
		thisEntity.yesteryear:SetLevel(2)
	else
		thisEntity.rewind:SetLevel(1)
		thisEntity.juncture:SetLevel(1)
		thisEntity.overtime:SetLevel(1)
		thisEntity.yesteryear:SetLevel(1)
	end
end


function AIThink(thisEntity)
	if not thisEntity:IsDominated() then
		if not thisEntity:IsAlive() then
			for _,unit in pairs( FindUnitsInRadius( DOTA_TEAM_BADGUYS, Vector( 0, 0, 0 ), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )) do
				if not unit:IsTower() or unit:IsHero() == false and not unit:GetName() == "npc_dota_creature" then
					unit:ForceKill(true)
					UTIL_Remove( unit )
				end
				return -1
			end
		end
		if not thisEntity:IsChanneling() then
			if thisEntity.rewind:IsFullyCastable() then
				local hpDeficitent = (thisEntity.rewind.tempList[thisEntity:GetUnitName()][1]["health"] - thisEntity:GetHealth())
				if hpDeficitent > thisEntity:GetMaxHealth()*0.10 then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
						AbilityIndex = thisEntity.rewind:entindex(),
						TargetIndex = thisEntity:entindex()
					})
					return 0.25
				else
					local target = AICore:HighestThreatHeroInRange(thisEntity, thisEntity.rewind:GetCastRange(), 10, false)
					if not target then target = AICore:WeakestEnemyHeroInRange( thisEntity, thisEntity.rewind:GetCastRange() + 200, false) end
					if target then
						local hpDeficittarget = (target:GetHealth() - thisEntity.rewind.tempList[target:GetUnitName()][1]["health"])
						local positionlapse = thisEntity.rewind.tempList[target:GetUnitName()][1]["position"]
						local positionnow = target:GetOrigin()
						local distancelapse = (thisEntity:GetOrigin() - positionlapse):Length2D()
						local distancenow = (thisEntity:GetOrigin() - positionnow):Length2D()
						if hpDeficittarget > thisEntity:GetMaxHealth()*0.10 then
							ExecuteOrderFromTable({
								UnitIndex = thisEntity:entindex(),
								OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
								AbilityIndex = thisEntity.rewind:entindex(),
								TargetIndex = target:entindex()
							})
							return 0.25
						elseif distancelapse < distancenow and distancelapse > (thisEntity:GetAttackRange() + thisEntity:GetAttackRangeBuffer()) then
							ExecuteOrderFromTable({
								UnitIndex = thisEntity:entindex(),
								OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
								AbilityIndex = thisEntity.rewind:entindex(),
								TargetIndex = target:entindex()
							})
							return 0.25
						end
					end
				end
			end
			if thisEntity.juncture:IsFullyCastable() and not thisEntity.chronoactive then
				local target = AICore:HighestThreatHeroInRange(thisEntity, thisEntity.juncture:GetCastRange()*1.2, 10, false)
				if not target then target = AICore:StrongestEnemyHeroInRange( thisEntity, thisEntity.juncture:GetCastRange()*1.2, false ) end
				if target then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
						AbilityIndex = thisEntity.juncture:entindex(),
						TargetIndex = target:entindex()
					})
					return 0.25
				end
			end
			if thisEntity.overtime:IsFullyCastable() and not thisEntity.chronoactive then
				local target = AICore:NearestEnemyHeroInRange(thisEntity, thisEntity.overtime:GetCastRange()/2, true )
				if target then
					ExecuteOrderFromTable({
						UnitIndex = thisEntity:entindex(),
						OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
						AbilityIndex = thisEntity.overtime:entindex()
					})
					return 1.2
				end
			end
			if (thisEntity.yesteryear:IsFullyCastable() and not thisEntity.overtime:IsFullyCastable() and not thisEntity.juncture:IsFullyCastable() and not thisEntity.chronoactive) 
			or (thisEntity.yesteryear:IsFullyCastable() and ( thisEntity:GetMana() < thisEntity.overtime:GetManaCost(-1) or thisEntity:GetMana() < thisEntity.juncture:GetManaCost(-1) ) )
			or thisEntity:GetHealth() <= thisEntity:GetMaxHealth()*0.35 then
				print("yesteryear")
				local interval = (thisEntity.yesteryear:GetChannelTime()+0.25)
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = thisEntity.yesteryear:entindex()
				})
				return interval
			end
			AICore:AttackHighestPriority( thisEntity )
			return 0.25
		else
			return 0.25
		end
	else
		return 0.25
	end
end
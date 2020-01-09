--[[
Broodking AI
]]

if IsServer() then
	require( "ai/ai_core" )
	function Spawn( entityKeyValues )
		AITimers:CreateTimer(function()
			if thisEntity and not thisEntity:IsNull() then
				return AIThink(thisEntity)
			end
		end)
		thisEntity.bloodlust = thisEntity:FindAbilityByName("boss14_bloodlust")
		thisEntity.impact = thisEntity:FindAbilityByName("boss_axe_big_impact")
		thisEntity.dunk = thisEntity:FindAbilityByName("boss_axe_slam_dunk")
		thisEntity.punch = thisEntity:FindAbilityByName("boss_axe_sucker_punch")
		thisEntity.leap = thisEntity:FindAbilityByName("boss_axe_feral_leap")
		local level = math.floor( GameRules:GetGameDifficulty() / 2 + 0.51 )
		AITimers:CreateTimer(0.1, function()
			thisEntity.bloodlust:SetLevel(level)
			thisEntity.impact:SetLevel(level)
			thisEntity.dunk:SetLevel(level)
			thisEntity.punch:SetLevel(level)
			thisEntity.leap:SetLevel(level)
		end)
	end


	function AIThink(thisEntity)
		if not thisEntity:IsDominated() and not thisEntity:IsChanneling() then
			local target = AICore:GetHighestPriorityTarget(thisEntity)
			if target and not target:IsNull() then
				
			end
			return AICore:AttackHighestPriority( thisEntity )
		else return AI_THINK_RATE end
	end
end

function CastSlamDunk(position, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.dunk:entindex()
	})
	return thisEntity.dunk:GetCastPoint() + 0.1
end

function CastSuckerPunch(position, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.punch:entindex()
	})
	return thisEntity.punch:GetCastPoint() + 0.1
end

function CastFeralLeap(position, thisEntity)
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.leap:entindex()
	})
	return thisEntity.leap:GetCastPoint() + 0.1
end
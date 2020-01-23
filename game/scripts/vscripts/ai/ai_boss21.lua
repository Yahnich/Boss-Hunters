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
		if thisEntity.leap then
			thisEntity.leap.lastCastTime = GameRules:GetGameTime()
		end
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
				local distance = CalculateDistance( target, thisEntity )
				if thisEntity.leap:IsFullyCastable() then
					if distance > thisEntity:GetAttackRange() + thisEntity:GetIdealSpeed() * 0.33 and distance <= thisEntity.leap:GetTrueCastRange() + thisEntity:GetIdealSpeed() then
						return CastFeralLeap( target:GetAbsOrigin(), thisEntity )
					end
					
					local enemies = thisEntity:FindEnemyUnitsInRadius( thisEntity:GetAbsOrigin(), thisEntity.leap:GetSpecialValueFor("radius") )
					if #enemies >= 2 then
						return CastFeralLeap( thisEntity:GetAbsOrigin() + ActualRandomVector(  thisEntity.leap:GetSpecialValueFor("radius") / 2 ), thisEntity )
					end
					if thisEntity.leap.lastCastTime <= GameRules:GetGameTime() + thisEntity.leap:GetEffectiveCooldown( -1 ) * 2 and distance <= thisEntity.leap:GetTrueCastRange() + thisEntity:GetIdealSpeed() then
						return CastFeralLeap( target:GetAbsOrigin() + ActualRandomVector(  thisEntity.leap:GetSpecialValueFor("radius") / 2 ), thisEntity )
					end
				end
				if thisEntity.dunk:IsFullyCastable() then
					if distance <= thisEntity.punch:GetTrueCastRange() then
						return CastSlamDunk( target:GetAbsOrigin(), thisEntity )
					end
				end
				if thisEntity.punch:IsFullyCastable() then
					if distance <= thisEntity.punch:GetTrueCastRange() then
						return CastSuckerPunch( target:GetAbsOrigin(), thisEntity )
					end
				end
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
	thisEntity.leap.lastCastTime = GameRules:GetGameTime()
	return thisEntity.leap:GetCastPoint() + 0.1
end
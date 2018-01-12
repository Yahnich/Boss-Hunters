--[[Author: Pizzalol
	Date: 09.02.2015.
	Forces the target to attack the caster]]
	--Modified by Sidearms
function superTauntStart( keys )
	local caster = keys.caster
	local target = keys.target
		
	--Probably should rename the taunts to be the same modifiers	
	if target:FindModifierByName("modifier_taunted") == nil then --if 1
		if target:FindModifierByName("modifier_skewer_datadriven") == nil then --if 2
			
				
				-- Clear the force attack target
				target:SetForceAttackTarget(nil)

				-- Give the attack order if the caster is alive
				-- otherwise forces the target to sit and do nothing
				if caster:IsAlive() then
					local order = 
					{
						UnitIndex = target:entindex(),
						OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
						TargetIndex = caster:entindex()
					}

					ExecuteOrderFromTable(order)
				else
					target:Stop()
				end

				-- Set the force attack target to be the caster
				target:SetForceAttackTarget(caster)
				
			
		end--if end 2
	end--if end 1
end

-- Clears the force attack target upon expiration
function superTauntEnd( keys )
	local target = keys.target

	target:SetForceAttackTarget(nil)
end

--Calculate the duration of the taunt based on the distance/base movement speed :/
function calcDuration( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifier = keys.modifier
	local baseDuration = ability:GetLevelSpecialValueFor("base_duration", ability:GetLevel() - 1)
	
	local minDistance = 250
	local targetMoveSpeed = target:GetBaseMoveSpeed() + target:GetMoveSpeedModifier(target:GetBaseMoveSpeed())
	local testDistance = caster:GetRangeToUnit(target)
	--print('RANGE: ' .. target:GetUnitName() .. ' is ' .. testDistance .. ' units away from you.')
	local targetMoveSpeed = caster:GetMoveSpeedModifier(caster:GetBaseMoveSpeed())
	
	if target:GetUnitName() == caster:GetUnitName() then
		ability:ApplyDataDrivenModifier(caster, target, modifier, {duration=10.0})
	elseif testDistance < minDistance and targetMoveSpeed > 250 then 
		ability:ApplyDataDrivenModifier(caster, target, modifier, {duration=1.0})
	elseif target:GetTeamNumber() == caster:GetTeamNumber() and target:GetUnitName() ~= caster:GetUnitName() then
		ability:ApplyDataDrivenModifier(caster, target, modifier, {duration=testDistance/targetMoveSpeed + baseDuration})
	else
		ability:ApplyDataDrivenModifier(caster, target, modifier, {duration=testDistance/targetMoveSpeed})
	end
end

--[[
Broodking AI
]]

require( "ai/ai_core" )
function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
	thisEntity.ball = thisEntity:FindAbilityByName("boss4_death_ball")
	thisEntity.summon = thisEntity:FindAbilityByName("boss4_summon_zombies")
	thisEntity.sacrifice = thisEntity:FindAbilityByName("boss4_sacrifice")
	thisEntity.tombstone = thisEntity:FindAbilityByName("boss4_tombstone")
	
	Timers:CreateTimer(function()
		if  math.floor(GameRules.gameDifficulty + 0.5) <= 2 then 
			thisEntity.ball:SetLevel(1)
			thisEntity.summon:SetLevel(1)
			thisEntity.sacrifice:SetLevel(1)
			thisEntity.tombstone:SetLevel(1)
		else
			thisEntity.ball:SetLevel(2)
			thisEntity.summon:SetLevel(2)
			thisEntity.sacrifice:SetLevel(2)
			thisEntity.tombstone:SetLevel(2)
			
			thisEntity:SetBaseMaxHealth(thisEntity:GetMaxHealth()*1.5)
			thisEntity:SetMaxHealth(thisEntity:GetMaxHealth()*1.5)
			thisEntity:SetHealth(thisEntity:GetMaxHealth())
		end
	end)
end


function AIThink()
	if not thisEntity:IsDominated() then
		-- AICore:AttackHighestPriority( thisEntity )
		return 0.25
	else return 0.25 end
end
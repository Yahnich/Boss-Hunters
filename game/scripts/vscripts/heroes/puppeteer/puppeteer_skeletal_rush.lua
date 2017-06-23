puppeteer_skeletal_rush = class({})

function puppeteer_skeletal_rush:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorPosition()
	
	local runDir = CalculateDirection(target, caster)
	local distance = self:GetSpecialValueFor("max_distance")
	
	for i = 1, self:GetSpecialValueFor("skeleton_amt") do
		local spawnPos = caster:GetAbsOrigin() + RandomVector(350)
		local skellington = caster:CreateSummon("npc_dota_puppeteer_skeleton_skirmisher", spawnPos)
		skellington:FindAbilityByName("skeleton_skirmisher_magic_conversion"):SetLevel(self:GetLevel())
		skellington:SetControllableByPlayer(-1, true)
		local currPos = skellington:GetAbsOrigin()
		local distanceTravelled = 0
		local existenceTime = 0
		Timers:CreateTimer(0.2, function()
			skellington:MoveToPositionAggressive(currPos + distance * runDir)
		end)
		Timers:CreateTimer(0.1, function()
			distanceTravelled = distanceTravelled + CalculateDistance(currPos, skellington:GetAbsOrigin())
			existenceTime = existenceTime + 0.1
			currPos = skellington:GetAbsOrigin()
			if distanceTravelled >= distance or existenceTime > 5 then
				skellington:ForceKill(true)
			else
				return 0.1
			end
		end)
	end
end

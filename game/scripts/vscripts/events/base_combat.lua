local function OnEntityKilled(self, event)
	local killedTarget = EntIndexToHScript(event.entindex_killed)
	local ROUND_END_DELAY = 3
	if killedTarget:IsRoundBoss() and self.enemiesToSpawn <= 0 then
		Timers:CreateTimer(ROUND_END_DELAY, function()
			for _, unit in ipairs( FindAllUnits({team = DOTA_UNIT_TARGET_TEAM_ENEMY}) ) do
				if unit:IsRoundBoss() and unit:IsAlive() then
					return
				end
			end
			self:EndEvent(true)
		end)
	elseif killedTarget:IsRealHero() then
		if not killedTarget:NotDead() then
			killedTarget:CreateTombstone()
		end
		Timers:CreateTimer( ROUND_END_DELAY, function()
			if RoundManager:EvaluateLoss() then
				self:EndEvent(false)
			end
		end)
	end
end

return OnEntityKilled
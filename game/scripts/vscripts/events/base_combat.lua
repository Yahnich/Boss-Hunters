local function OnEntityKilled(self, event)
	if not event.entindex_killed then return end
	local killedTarget = EntIndexToHScript(event.entindex_killed)
	if not killedTarget or not self then return end
	if killedTarget:IsRoundBoss() and self.enemiesToSpawn <= 0 then
		for _, unit in ipairs( FindAllUnits({team = DOTA_UNIT_TARGET_TEAM_ENEMY}) ) do
			if unit:IsRoundBoss() and unit:IsAlive() then
				return
			end
		end
		Timers:CreateTimer(3, function()
			self:EndEvent(true)
		end)
	elseif killedTarget:IsRealHero() then
		if not killedTarget:NotDead() then
			killedTarget:CreateTombstone()
		end
		Timers:CreateTimer(3, function()
			if RoundManager:EvaluateLoss() then
				self.eventEnded = true
				self:EndEvent(false)
			end
		end)
	end
end

return OnEntityKilled
local function OnEntityKilled(self, event)
	local killedTarget = EntIndexToHScript(event.entindex_killed)
	if not killedTarget or not self then return end
	if killedTarget:IsRoundBoss() and self.enemiesToSpawn <= 0 then
		Timers:CreateTimer(3, function()
			if self.eventEnded then return end
			for _, unit in ipairs( FindAllUnits({team = DOTA_UNIT_TARGET_TEAM_ENEMY}) ) do
				print( unit:IsRoundBoss() and unit:IsAlive(), unit:GetName() )
				if unit:IsRoundBoss() and unit:IsAlive() then
					return
				end
			end
			self.eventEnded = true
			self:EndEvent(true)
		end)
	elseif killedTarget:IsRealHero() then
		if not killedTarget:NotDead() then
			killedTarget:CreateTombstone()
		end
		Timers:CreateTimer(3, function()
			if self.eventEnded then return end
			if RoundManager:EvaluateLoss() then
				self.eventEnded = true
				self:EndEvent(false)
			end
		end)
	end
end

return OnEntityKilled
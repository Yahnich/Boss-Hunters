local function OnEntityKilled(self, event)
	local EntityKillCatch = function( ... )
		if not event.entindex_killed then return end
		local killedTarget = EntIndexToHScript(event.entindex_killed)
		if not killedTarget or not self or self.eventEnded then return end
		if killedTarget:IsRoundBoss() and self.enemiesToSpawn <= 0 then
			for _, unit in ipairs( FindAllUnits({team = DOTA_UNIT_TARGET_TEAM_ENEMY}) ) do
				if unit:IsRoundBoss() and unit:IsAlive() then
					return
				end
			end
			Timers:CreateTimer(3, function()
				print(self)
				print(self.EndEvent)
				self:EndEvent(true)
			end)
		elseif killedTarget:IsRealHero() then
			if not killedTarget:NotDead() then
				killedTarget:CreateTombstone()
			end
			if RoundManager:EvaluateLoss() then
				Timers:CreateTimer(3, function()
					if RoundManager:EvaluateLoss() then
						self:EndEvent(false)
					end
				end)
			end
		end
	end
	status, err, ret = xpcall(EntityKillCatch, debug.traceback, self, event )
	if not status  and not self.gameHasBeenBroken then
		SendErrorReport(err)
	end
end

return OnEntityKilled
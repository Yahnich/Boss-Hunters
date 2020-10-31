TIMERS_VERSION = "1.06"
require('libraries/binheap')

--[[
	1.06 modified by Celireor (now uses binary heap priority queue instead of iteration to determine timer of shortest duration)
	DO NOT MODIFY A REALTIME TIMER TO USE GAMETIME OR VICE VERSA MIDWAY WITHOUT FIRST REMOVING AND RE-ADDING THE TIMER
	-- A timer running every second that starts immediately on the next frame, respects pauses
	AITimers:CreateTimer(function()
			print ("Hello. I'm running immediately and then every second thereafter.")
			return 1.0
		end
	)
	-- The same timer as above with a shorthand call
	AITimers(function()
		print ("Hello. I'm running immediately and then every second thereafter.")
		return 1.0
	end)
	-- A timer which calls a function with a table context
	AITimers:CreateTimer(GameMode.someFunction, GameMode)
	-- A timer running every second that starts 5 seconds in the future, respects pauses
	AITimers:CreateTimer(5, function()
			print ("Hello. I'm running 5 seconds after you called me and then every second thereafter.")
			return 1.0
		end
	)
	-- 10 second delayed, run once using gametime (respect pauses)
	AITimers:CreateTimer({
		endTime = 10, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
		callback = function()
			print ("Hello. I'm running 10 seconds after when I was started.")
		end
	})
	-- 10 second delayed, run once regardless of pauses
	AITimers:CreateTimer({
		useGameTime = false,
		endTime = 10, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
		callback = function()
			print ("Hello. I'm running 10 seconds after I was started even if someone paused the game.")
		end
	})
	-- A timer running every second that starts after 2 minutes regardless of pauses
	AITimers:CreateTimer("uniqueTimerString3", {
		useGameTime = false,
		endTime = 120,
		callback = function()
			print ("Hello. I'm running after 2 minutes and then every second thereafter.")
			return 1
		end
	})
]]



TIMERS_THINK = 0.01

if AITimers == nil then
	print ( '[AITimers] creating AITimers' )
	AITimers = {}
	setmetatable(AITimers, {
		__call = function(t, ...)
			return t:CreateTimer(...)
		end
	})
	--AITimers.__index = AITimers
end

function AITimers:start()
	self.started = true
	AITimers = self
	self:InitializeTimers()
	self.nextTickCallbacks = {}

	local ent = SpawnEntityFromTableSynchronous("info_target", {targetname="aitimers_lua_thinker"})
	ent:SetThink("Think", self, "AIimers", TIMERS_THINK)
end

function AITimers:Think()
	local nextTickCallbacks = MergeTables({}, AITimers.nextTickCallbacks)
	AITimers.nextTickCallbacks = {}
	for _, cb in ipairs(nextTickCallbacks) do
		local status, result = xpcall(cb, debug.traceback)
		if not status then
			AITimers:HandleEventError(result)
		end
	end
	if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return
	end

	-- Track game time, since the dt passed in to think is actually wall-clock time not simulation time.
	local now = GameRules:GetGameTime()

	-- Process timers
	self:ExecuteTimers(self.realTimeHeap, Time())
	self:ExecuteTimers(self.gameTimeHeap, GameRules:GetGameTime())

	return TIMERS_THINK
end

function AITimers:ExecuteTimers(timerList, now)
	--Empty timer, ignore
	if not timerList[1] then return end

	--Timers are alr. sorted by end time upon insertion
	local currentTimer = timerList[1]

	currentTimer.endTime = currentTimer.endTime or now
	--Check if timer has finished
	if now >= currentTimer.endTime then
		-- Remove from timers list
		timerList:Remove(currentTimer)
		AITimers.runningTimer = k
		AITimers.removeSelf = false

		-- Run the callback
		local status, timerResult
		if currentTimer.context then
			status, timerResult = xpcall(function() return currentTimer.callback(currentTimer.context, currentTimer) end, debug.traceback)
		else
			status, timerResult = xpcall(function() return currentTimer.callback(currentTimer) end, debug.traceback)
		end

		AITimers.runningTimer = nil

		-- Make sure it worked
		if status then
			-- Check if it needs to loop
			if timerResult and not AITimers.removeSelf then
				-- Change its end time

				currentTimer.endTime = currentTimer.endTime + timerResult

				timerList:Insert(currentTimer)
			end

			-- Update timer data
			--self:UpdateTimerData()
		else
			-- Nope, handle the error
			AITimers:HandleEventError(timerResult)
		end
		--run again!
		self:ExecuteTimers(timerList, now)
	end
end

function AITimers:HandleEventError(err)
	if IsInToolsMode() then
		print(err)
	end
end

function AITimers:CreateTimer(arg1, arg2, context)
	local timer
	if type(arg1) == "function" then
		if arg2 ~= nil then
			context = arg2
		end
		timer = {callback = arg1}
	elseif type(arg1) == "table" then
		timer = arg1
	elseif type(arg1) == "number" then
		timer = {endTime = arg1, callback = arg2}
	end
	if not timer.callback then
		print("Invalid timer created")
		return
	end

	local now = GameRules:GetGameTime()
	local timerHeap = self.gameTimeHeap
	if timer.useGameTime ~= nil and timer.useGameTime == false then
		now = Time()
		timerHeap = self.realTimeHeap
	end

	if timer.endTime == nil then
		timer.endTime = now
	else
		timer.endTime = now + timer.endTime
	end

	timer.context = context

	timerHeap:Insert(timer)

	return timer
end

function AITimers:NextTick(callback)
	table.insert(AITimers.nextTickCallbacks, callback)
end

function AITimers:RemoveTimer(name)
	local timerHeap = self.gameTimeHeap
	if name.useGameTime ~= nil and name.useGameTime == false then
		timerHeap = self.realTimeHeap
	end

	timerHeap:Remove(name)
	if AITimers.runningTimer == name then
		AITimers.removeSelf = true
	end
end

function AITimers:InitializeTimers()
	self.realTimeHeap = BinaryHeap("endTime")
	self.gameTimeHeap = BinaryHeap("endTime")
end

if not AITimers.started then AITimers:start() end

GameRules.AITimers = AITimers
if EventManager == nil then
	print ( 'creating event manager' )
	EventManager = {}
	EventManager.__index = EventManager
end

function EventManager:new( o )
	o = o or {}
	setmetatable( o, EventManager )
	return o
end

PUBLIC_EVENTS = {["boss_hunters_event_started"] = {},
				 ["boss_hunters_event_finished"] = {},
				 ["boss_hunters_raid_finished"] = {},
				 ["boss_hunters_zone_finished"] = {},
				 ["boss_hunters_game_finished"] = {}}
				 
function EventManager:SubscribeListener(event, callback)
	local eventTable = PUBLIC_EVENTS[event]
	local id = DoUniqueString("event")
	eventTable[id] = callback
	return id
end

function EventManager:FireEvent(event, args)
	for id, callback in pairs( PUBLIC_EVENTS[event] ) do
		status, err, ret = pcall(callback, args)
		if not status  and not self.gameHasBeenBroken then
			self:SendErrorReport(err)
		end
	end
end

function EventManager:UnsubscribeListener(event, id)
	local eventTable = PUBLIC_EVENTS[event]
	eventTable[id] = nil
end

function EventManager:SendErrorReport(err)
	self.gameHasBeenBroken = true
	Notifications:BottomToAll({text="An error has occurred! Please screenshot this: "..err, duration=15.0})
	print(err)
end

function EventManager:CreateNewEvent(name)
	PUBLIC_EVENTS[name] = {}
end

function EventManager:RemoveEvent(name)
	PUBLIC_EVENTS[name] = nil
end

function EventManager:ShowErrorMessage(pID, sError)
	local player = PlayerResource:GetPlayer(pID)
	if player then
		CustomGameEventManager:Send_ServerToPlayer(player, "bh_show_error_message", {_error = sError or ""} )
	end
end
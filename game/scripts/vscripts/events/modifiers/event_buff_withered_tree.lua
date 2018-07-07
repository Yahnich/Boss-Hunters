event_buff_withered_tree = class(relicBaseClass)

function event_buff_withered_tree:OnCreated(kv)
	if IsServer() then
		self:SetStackCount(3)
		self.funcID = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
	end
end

function event_buff_withered_tree:OnEventFinished(args)
	EVENT_TYPE_EVENT = 3
	print(args.eventType)
	if args.eventType ~= EVENT_TYPE_EVENT then
		self:DecrementStackCount()
		if self:GetStackCount() == 0 then
			self:Destroy()
		end
	end
end

function event_buff_withered_tree:OnDestroy()
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcID)
	end
end

function event_buff_withered_tree:GetBonusExp( params )
    return 25
end

function event_buff_withered_tree:IsHidden()
    return false
end
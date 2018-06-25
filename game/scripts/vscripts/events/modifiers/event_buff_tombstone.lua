event_buff_tombstone = class(relicBaseClass)

function event_buff_tombstone:OnCreated(kv)
	if IsServer() then
		self:SetStackCount(3)
		self.funcID = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
	end
end

function event_buff_tombstone:OnEventFinished(args)
	EVENT_TYPE_EVENT = 3
	if args.eventType ~= EVENT_TYPE_EVENT then
		
		self:DecrementStackCount()
		if self:GetStackCount() == 0 then
			self:Destroy()
		end
	end
end

function event_buff_tombstone:OnDestroy()
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcID)
	end
end

function event_buff_tombstone:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_EVASION_CONSTANT,
    }

    return funcs
end

function event_buff_tombstone:GetModifierEvasion_Constant( params )
    return 30
end

function event_buff_tombstone:IsHidden()
    return false
end
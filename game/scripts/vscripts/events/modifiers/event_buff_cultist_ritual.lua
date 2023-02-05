event_buff_cultist_ritual = class(relicBaseClass)

function event_buff_cultist_ritual:OnCreated(kv)
	if IsServer() then
		self:SetStackCount(1)
		self.funcID = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
	end
end

function event_buff_cultist_ritual:OnEventFinished(args)
	EVENT_TYPE_EVENT = 3
	if args.eventType ~= EVENT_TYPE_EVENT then
		self:DecrementStackCount()
		if self:GetStackCount() == 0 then
			self:Destroy()
		end
	end
end

function event_buff_cultist_ritual:OnDestroy()
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcID)
	end
end

function event_buff_cultist_ritual:GetBonusGold()
    return -50
end

function event_buff_cultist_ritual:GetBonusExp()
    return -50
end

function event_buff_cultist_ritual:GetTexture()
    return "custom/healing_disabled"
end

function event_buff_cultist_ritual:IsDebuff()
	return true
end

function event_buff_cultist_ritual:IsCurse()
	return true
end
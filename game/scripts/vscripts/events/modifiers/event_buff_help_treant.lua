event_buff_help_treant = class(relicBaseClass)

function event_buff_help_treant:OnCreated(kv)
	if IsServer() then
		self:SetStackCount(4)
		self.funcID = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
	end
end

function event_buff_help_treant:OnEventFinished(args)
	EVENT_TYPE_EVENT = 3
	if args.eventType ~= EVENT_TYPE_EVENT then
		
		self:DecrementStackCount()
		if self:GetStackCount() == 0 then
			self:Destroy()
		end
	end
end

function event_buff_help_treant:OnDestroy()
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcID)
	end
end

function event_buff_help_treant:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    }

    return funcs
end

function event_buff_help_treant:GetModifierConstantHealthRegen( params )
    return 25
end

function event_buff_help_treant:IsHidden()
    return false
end
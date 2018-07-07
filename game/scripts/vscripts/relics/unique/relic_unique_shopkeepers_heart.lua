relic_unique_shopkeepers_heart = class(relicBaseClass)

function relic_unique_shopkeepers_heart:OnCreated(kv)
	if IsServer() then
		self:SetStackCount(3)
		self.funcID = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
	end
end

function relic_unique_shopkeepers_heart:OnEventFinished(args)
	EVENT_TYPE_EVENT = 3
	self:GetParent():AddGold( 150 )
end

function relic_unique_shopkeepers_heart:OnDestroy()
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcID)
	end
end
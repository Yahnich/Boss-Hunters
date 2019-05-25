relic_limit_breaker = class(relicBaseClass)

function relic_limit_breaker:OnCreated(kv)
	if IsServer() then
		self.funcIDf = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
		self.funcIDs = EventManager:SubscribeListener("boss_hunters_event_started", function(args) self:OnEventStarted(args) end)
	end
end

function relic_limit_breaker:OnEventFinished(args)
	self:SetStackCount(0)
	self:StartIntervalThink(-1)
end

function relic_limit_breaker:OnEventStarted(args)
	self:StartIntervalThink(1)
end

function relic_limit_breaker:OnIntervalThink()
	self:IncrementStackCount()
end

function relic_limit_breaker:OnDestroy()
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcIDf)
		EventManager:UnsubscribeListener("boss_hunters_event_started", self.funcIDs)
	end
end

function relic_limit_breaker:GetModifierAttackSpeedBonus()
	return self:GetStackCount()
end


function relic_limit_breaker:GetModifierAttackSpeedLimitBonus(params)
	return 900
end
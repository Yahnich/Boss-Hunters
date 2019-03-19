relic_olive_branch = class(relicBaseClass)

function relic_olive_branch:OnCreated(kv)
	if IsServer() then
		self.funcID = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
	end
end

function relic_olive_branch:OnDestroy()
	if IsServer() then
		EventManager:SubscribeListener("boss_hunters_event_finished", self.funcID)
	end
end

function relic_olive_branch:OnEventFinished(args)
	EVENT_TYPE_EVENT = 3
	if args.eventType ~= EVENT_TYPE_EVENT then
		if self.gotHit and not self:GetParent():HasModifier("relic_ritual_candle") then
			self:GetParent():AddGold( -150 )
		else
			self:GetParent():AddGold( 300 )
		end
		self.gotHit = false
	end
end

function relic_olive_branch:OnDestroy()
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcID)
	end
end

function relic_olive_branch:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function relic_olive_branch:OnDeath(params)
	if params.unit == self:GetParent() then
		self.gotHit = true
	end
end
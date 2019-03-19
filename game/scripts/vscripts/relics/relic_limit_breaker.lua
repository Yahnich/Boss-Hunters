relic_limit_breaker = class(relicBaseClass)


modifier_alchemist_alchemists_greed_talent = class({})
LinkLuaModifier("modifier_alchemist_alchemists_greed_talent", "heroes/hero_alchemist/alchemist_alchemists_greed", 0)

function modifier_alchemist_alchemists_greed_talent:OnCreated(kv)
	if IsServer() then
		self.funcIDf = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
		self.funcIDs = EventManager:SubscribeListener("boss_hunters_event_started", function(args) self:OnEventStarted(args) end)
	end
end

function modifier_alchemist_alchemists_greed_talent:OnEventFinished(args)
	self:SetStackCount(0)
	self:StartIntervalThink(-1)
end

function modifier_alchemist_alchemists_greed_talent:OnEventStarted(args)
	self:StartIntervalThink(1)
end

function modifier_alchemist_alchemists_greed_talent:OnIntervalThink()
	self:IncrementStackCount()
end

function modifier_alchemist_alchemists_greed_talent:OnDestroy()
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcIDf)
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcIDs)
	end
end

function modifier_alchemist_alchemists_greed_talent:GetModifierAttackSpeedBonus()
	return self:GetStackCount()
end


function relic_limit_breaker:GetModifierAttackSpeedLimitBonus(params)
	return 900
end
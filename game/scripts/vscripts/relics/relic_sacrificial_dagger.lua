relic_sacrificial_dagger = class(relicBaseClass)

function relic_sacrificial_dagger:OnCreated()
	self:SetStackCount(1)
	if IsServer() then
		self.funcID = EventManager:SubscribeListener("boss_hunters_raid_finished", function(args) self:OnRaidFinished(args) end)
	end
end

function relic_sacrificial_dagger:OnDestroy()
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_raid_finished", self.funcID)
	end
end

function relic_sacrificial_dagger:OnRaidFinished(args)
	self:SetStackCount(1)
end

function relic_sacrificial_dagger:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function relic_sacrificial_dagger:OnDeath(params)
	if params.unit == self:GetParent() and self:GetStackCount() > 0 and not self:GetParent():WillReincarnate() then
		self:DecrementStackCount()
		GameRules:RefreshPlayers()
	end
end

function relic_sacrificial_dagger:IsHidden()
	return self:GetStackCount() == 0
end

function relic_sacrificial_dagger:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end
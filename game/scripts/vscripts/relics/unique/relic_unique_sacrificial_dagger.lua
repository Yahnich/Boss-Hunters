relic_unique_sacrificial_dagger = class(relicBaseClass)

function relic_unique_sacrificial_dagger:OnCreated()
	self:SetStackCount(1)
	if IsServer() then
		self.funcID = EventManager:SubscribeListener("boss_hunters_raid_finished", function(args) self:OnEventFinished(args) end)
	end
end

function relic_unique_sacrificial_dagger:OnEventFinished(args)
	self:SetStackCount(1)
end

function relic_unique_sacrificial_dagger:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function relic_unique_sacrificial_dagger:OnDeath(params)
	if params.unit == self:GetParent() and self:GetStackCount() > 0 then
		self:DecrementStackCount()
		GameRules:RefreshPlayers()
	end
end

function relic_unique_sacrificial_dagger:IsHidden()
	return false
end

function relicBaseClass:AllowIllusionDuplicate()
	return false
end
relic_rotting_flesh = class(relicBaseClass)

function relic_rotting_flesh:OnCreated(kv)
	self:SetStackCount(0)
	if IsServer() then
		self.funcID = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
	end
end

function relic_rotting_flesh:OnEventFinished(args)
	self:SetStackCount(0)
end

function relic_rotting_flesh:OnDestroy()
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcID)
	end
end

function relic_rotting_flesh:DeclareFunctions()
	local decFuncs = {MODIFIER_PROPERTY_REINCARNATION}

	return decFuncs
end

function relic_rotting_flesh:ReincarnateTime()
	if IsServer() then  
		if self:GetStackCount() == 0 and self:GetCaster():IsRealHero() then
			self:SetStackCount(1)
			self:GetCaster():EmitSound("Hero_SkeletonKing.Reincarnate")
			self:GetCaster():RefreshAllCooldowns(true)
			return 7
		end

		return nil
	end
end

function relic_rotting_flesh:DestroyOnExpire()
	return false
end

function relic_rotting_flesh:IsHidden()
	return self:GetStackCount() == 1
end
relic_rotting_flesh = class(relicBaseClass)

function relic_rotting_flesh:OnCreated(kv)
	self:SetStackCount(0)
	self:GetCaster():HookInModifier("GetReincarnationDelay", self)
	if IsServer() then
		self.funcID = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
	end
end

function relic_rotting_flesh:OnEventFinished(args)
	self:SetStackCount(0)
end

function relic_rotting_flesh:OnDestroy()
	self:GetCaster():HookOutModifier("GetReincarnationDelay", self)
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcID)
	end
end

function relic_rotting_flesh:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function relic_rotting_flesh:GetReincarnationDelay()
	if IsServer() then
		if self:GetStackCount() == 0 and self:GetCaster():IsRealHero() then
			self:SetStackCount(1)
			self:GetCaster():EmitSound("Hero_SkeletonKing.Reincarnate")
			self:GetCaster():RefreshAllCooldowns(true)
			AddFOWViewer( self:GetCaster():GetTeam(), self:GetCaster():GetAbsOrigin(), 600, 7, true ) 
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

function relic_rotting_flesh:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end
event_buff_offering_curse = class(relicBaseClass)

function event_buff_offering_curse:OnCreated(kv)
	if IsServer() then
		self:GetParent():SetBuyBackDisabledByReapersScythe( true )
		self.funcID = EventManager:SubscribeListener("boss_hunters_raid_finished", function(args) self:OnRaidFinished(args) end)
		self:StartIntervalThink(1)
	end
end

function event_buff_offering_curse:OnIntervalThink()
	self:GetParent():SetTombstoneDisabled(true)
end

function event_buff_offering_curse:OnRaidFinished(args)
	self:GetParent():SetBuyBackDisabledByReapersScythe( false )
	self:GetParent():SetTombstoneDisabled( false )
	self:Destroy()
end

function event_buff_offering_curse:OnDestroy()
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_raid_finished", self.funcID)
	end
end

function event_buff_offering_curse:IsHidden()
    return false
end

function event_buff_offering_curse:IsDebuff()
    return true
end

function event_buff_offering_curse:IsPurgable()
    return false
end
relic_mask_of_janus = class(relicBaseClass)

if IsServer() then
	function relic_mask_of_janus:RerollRelic()
		local hero = self:GetParent()
		local pID = hero:GetPlayerID()
		if self:GetParent():HasModifier("relic_ritual_candle") then return end
		local relicList = {}
		for item, relic in pairs( hero.ownedRelics ) do
			if relic.name and relic.name ~= "relic_mask_of_janus" then	
				table.insert(relicList, relic.name)
			end
		end
		local relicName = relicList[RandomInt(1, #relicList)]
		RelicManager:RemoveRelicOnPlayer(relicName, pID)
		hero:AddRelic( RelicManager:RollRandomRelicForPlayer(pID).name )
	end
end


function relic_mask_of_janus:OnCreated()
	if IsServer() then
		print("?")
		self.funcID = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
	end
end

function relic_mask_of_janus:OnEventFinished(args)
	EVENT_TYPE_EVENT = 3
	if args.eventType ~= EVENT_TYPE_EVENT then
		self:RerollRelic()
	end
end

function relic_mask_of_janus:OnDestroy()
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcID)
	end
end
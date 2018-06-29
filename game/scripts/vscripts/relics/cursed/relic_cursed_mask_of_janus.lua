relic_cursed_mask_of_janus = class(relicBaseClass)

if IsServer() then
	function relic_cursed_mask_of_janus:RerollRelic()
		local hero = self:GetParent()
		local pID = hero:GetPlayerID()
		if self:GetParent():HasModifier("relic_unique_ritual_candle") then return end
		local relicList = {}
		for item, relic in pairs( hero.ownedRelics ) do
			if relic and relic ~= "relic_cursed_mask_of_janus" then
				table.insert(relicList, relic)
			end
		end
		local relic = relicList[RandomInt(1, #relicList)]
		RelicManager:RemoveRelicOnPlayer(relic, pID)
		local roll = RandomInt( 1, 3 )
		if roll == 1 then
			hero:AddRelic( RelicManager:RollRandomGenericRelicForPlayer(pID) )
		elseif roll == 2 then
			hero:AddRelic( RelicManager:RollRandomCursedRelicForPlayer(pID) )
		else
			hero:AddRelic( RelicManager:RollRandomUniqueRelicForPlayer(pID) )
		end
	end
end


function relic_cursed_mask_of_janus:OnCreated()
	if IsServer() then
		self.funcID = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
	end
end

function relic_cursed_mask_of_janus:OnEventFinished(args)
	EVENT_TYPE_EVENT = 3
	if args.eventType ~= EVENT_TYPE_EVENT then
		self:RerollRelic()
	end
end

function relic_cursed_mask_of_janus:OnDestroy()
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcID)
	end
end
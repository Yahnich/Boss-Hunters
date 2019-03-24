relic_stick = class(relicBaseClass)

function relic_stick:OnCreated()
	self:SetStackCount(1)
	if IsServer() then
		self.funcID = EventManager:SubscribeListener("boss_hunters_event_finished", function(args) self:OnEventFinished(args) end)
	end
end

function relic_stick:OnEventFinished(args)
	EVENT_TYPE_EVENT = 3
	if args.eventType ~= EVENT_TYPE_EVENT then
		self:SetStackCount( math.ceil(self:GetStackCount() * 1.6) )
		if self:GetStackCount() >= 75 then
			local parent = self:GetParent()
			local ability = self:GetAbility()
			parent.ownedRelics[ability:entindex()] = "relic_stick2"
			LinkLuaModifier("relic_stick2", "relics/relic_stick2", LUA_MODIFIER_MOTION_NONE)
			parent:AddNewModifier( parent, ability, "relic_stick2", {})
			if parent:GetPlayerOwner() then
				CustomGameEventManager:Send_ServerToAllClients( "dota_player_update_relic_inventory", { hero = parent:entindex(), relics = parent.ownedRelics } )
			end
			self:Destroy()
		end
	end
end

function relic_stick:OnDestroy()
	if IsServer() then
		EventManager:UnsubscribeListener("boss_hunters_event_finished", self.funcID)
	end
end

function relic_stick:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE}
end

function relic_stick:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end
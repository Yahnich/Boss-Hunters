relic_cursed_phoenix_down = class(relicBaseClass)

function relic_cursed_phoenix_down:OnDestroy()
	if IsServer() then
		PlayerResource:SetCustomBuybackCost(self:GetParent():GetPlayerID(), 100 + RoundManager:GetEventsFinished() * 25)
		PlayerResource:SetCustomBuybackCooldown(self:GetParent():GetPlayerID(), self:GetParent():GetBuybackCooldownTime( )  )
		self:GetParent():SetBuybackCooldownTime( 120 )
	end
end

function relic_cursed_phoenix_down:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH, MODIFIER_EVENT_ON_ABILITY_FULLY_CAST, MODIFIER_EVENT_ON_ABILITY_END_CHANNEL}
end

function relic_cursed_phoenix_down:OnDeath(params)
	if params.unit == self:GetParent() then
		self:GetParent():SetBuyBackDisabledByReapersScythe( true )
		if not self:GetParent():HasModifier("relic_unique_ritual_candle") then
			self:GetParent():SetBuybackCooldownTime( 0 )
			PlayerResource:SetCustomBuybackCooldown(self:GetParent():GetPlayerID(), 0)
			PlayerResource:SetCustomBuybackCost(self:GetParent():GetPlayerID(), 0)
		else
			PlayerResource:SetCustomBuybackCost(self:GetParent():GetPlayerID(), 100 + RoundManager:GetEventsFinished() * 25)
			PlayerResource:SetCustomBuybackCooldown(self:GetParent():GetPlayerID(), 60  )
			self:GetParent():SetBuybackCooldownTime( 60  )
		end
	end
end

function relic_cursed_phoenix_down:OnAbilityFullyCast(params)
	if params.ability:GetAbilityName() == "item_tombstone" and params.ability:GetPurchaser() == self:GetParent() then
		self.getCurrentChanneler = params.unit
		self:GetParent():SetBuyBackDisabledByReapersScythe( false )
		self:GetParent():SetBuybackCooldownTime( 0 )
		PlayerResource:SetCustomBuybackCooldown(self:GetParent():GetPlayerID(), 0)
		PlayerResource:SetCustomBuybackCost(self:GetParent():GetPlayerID(), 0)
	end
end

function relic_cursed_phoenix_down:OnAbilityEndChannel(params)
	if params.ability:GetAbilityName() == "item_tombstone" and self.getCurrentChanneler == params.unit then
		self:GetParent():SetBuyBackDisabledByReapersScythe( true )
		if not self:GetParent():HasModifier("relic_unique_ritual_candle") then
			self:GetParent():SetBuybackCooldownTime( 0 )
			PlayerResource:SetCustomBuybackCooldown(self:GetParent():GetPlayerID(), 0)
			PlayerResource:SetCustomBuybackCost(self:GetParent():GetPlayerID(), 0)
		else
			PlayerResource:SetCustomBuybackCost(self:GetParent():GetPlayerID(), 100 + RoundManager:GetEventsFinished() * 25)
			PlayerResource:SetCustomBuybackCooldown(self:GetParent():GetPlayerID(), 60  )
			self:GetParent():SetBuybackCooldownTime( 60 )
		end
	end
end
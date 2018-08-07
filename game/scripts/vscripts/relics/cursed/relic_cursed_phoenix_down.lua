relic_cursed_phoenix_down = class(relicBaseClass)

function relic_cursed_phoenix_down:OnCreated()
	if IsServer() and self:GetParent():IsRealHero() then
		self:OnIntervalThink()
		self:StartIntervalThink(0.1)
	end
end

function relic_cursed_phoenix_down:OnIntervalThink()
	if self:GetParent().tombstoneEntity and self:GetParent().tombstoneEntity:IsNull() then self:GetParent().tombstoneEntity = nil end
	if ( self:GetParent().tombstoneEntity and self:GetParent().tombstoneEntity:IsChanneling() ) then
		self:GetParent():SetBuyBackDisabledByReapersScythe( false )
		PlayerResource:SetCustomBuybackCooldown(self:GetParent():GetPlayerID(), 0)
		PlayerResource:SetCustomBuybackCost(self:GetParent():GetPlayerID(), 0)
	else
		self:GetParent():SetBuyBackDisabledByReapersScythe( not self:GetParent():HasModifier("relic_unique_ritual_candle") )
	end
	if self:GetParent():HasModifier("relic_unique_ritual_candle") and self:GetParent().tombstoneEntity and not self:GetParent().tombstoneEntity:IsChanneling() then
		PlayerResource:SetCustomBuybackCost(hero:GetPlayerID(), 100 + RoundManager:GetEventsFinished() * 25)
		PlayerResource:SetCustomBuybackCooldown(self:GetParent():GetPlayerID(), 120)
	end
end
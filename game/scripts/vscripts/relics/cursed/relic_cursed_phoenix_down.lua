relic_cursed_phoenix_down = class(relicBaseClass)

function relic_cursed_phoenix_down:OnCreated()
	if IsServer() then
		self:OnIntervalThink()
		self:StartIntervalThink(0.1)
	end
end

function relic_cursed_phoenix_down:OnIntervalThink()

	if self:GetParent().tombstoneEntity and self:GetParent().tombstoneEntity:IsNull() then self:GetParent().tombstoneEntity = nil end
	
	PlayerResource:SetCustomBuybackCooldown(self:GetParent():GetPlayerID(), 0)
	PlayerResource:SetCustomBuybackCost(self:GetParent():GetPlayerID(), 0)
	if ( not self:GetParent():IsAlive() and self:GetParent().tombstoneEntity and self:GetParent().tombstoneEntity:IsChanneling() ) or self:GetParent():HasModifier("relic_unique_ritual_candle") then
		self:GetParent():SetBuyBackDisabledByReapersScythe( false )
	else
		self:GetParent():SetBuyBackDisabledByReapersScythe( true )
	end
end
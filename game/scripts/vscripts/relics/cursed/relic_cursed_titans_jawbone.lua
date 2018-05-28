relic_cursed_titans_jawbone = class(relicBaseClass)

function relic_cursed_titans_jawbone:OnCreated()
	if IsServer() then
		self:SetStackCount( self:GetParent():GetMaxHealth() * 1 )
		self:GetParent():CalculateStatBonus()
		self:StartIntervalThink(0.33)
	end
end

function relic_cursed_titans_jawbone:OnIntervalThink()
	if IsServer() then
		local hpPct = self:GetParent():GetHealth() / self:GetParent():GetMaxHealth()

		self:SetStackCount( 0 )
		self:GetParent():CalculateStatBonus()
		self:SetStackCount( self:GetParent():GetMaxHealth() * 1 )
		self:GetParent():CalculateStatBonus()
		self:GetParent():SetHealth( hpPct * self:GetParent():GetMaxHealth() )
	end
end

function relic_cursed_titans_jawbone:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS, MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function relic_cursed_titans_jawbone:GetModifierExtraHealthBonus()
	return self:GetStackCount()
end

function relic_cursed_titans_jawbone:GetModifierTotalDamageOutgoing_Percentage()
	if not self:GetParent():HasModifier("relic_unique_ritual_candle") then return -33 end
end
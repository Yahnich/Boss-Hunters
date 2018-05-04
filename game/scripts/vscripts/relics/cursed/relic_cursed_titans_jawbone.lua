relic_cursed_titans_jawbone = class({})

function relic_cursed_titans_jawbone:OnCreated()
	if IsServer() then
		self:SetStackCount( self:GetParent():GetMaxHealth() * 1 )
		self:GetParent():CalculateStatBonus()
		self:StartIntervalThink(0.15)
	end
end

function relic_cursed_titans_jawbone:OnIntervalThink()
	if IsServer() then
		local hpPct = self:GetParent():GetHealthPercent()
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
	return -33
end


function relic_cursed_titans_jawbone:IsHidden()
	return true
end

function relic_cursed_titans_jawbone:IsPurgable()
	return false
end

function relic_cursed_titans_jawbone:RemoveOnDeath()
	return false
end

function relic_cursed_titans_jawbone:IsPermanent()
	return true
end

function relic_cursed_titans_jawbone:AllowIllusionDuplicate()
	return true
end

function relic_cursed_titans_jawbone:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
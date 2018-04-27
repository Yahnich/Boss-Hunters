relic_cursed_phoenix_down = class({})

function relic_cursed_phoenix_down:OnCreated()
	if IsServer() then
		PlayerResource:SetCustomBuybackCooldown(self:GetParent():GetPlayerID(), 0)
		PlayerResource:SetCustomBuybackCost(self:GetParent():GetPlayerID(), 0)
		self:GetParent():SetBuyBackDisabledByReapersScythe( true )
		self:StartIntervalThink(0.33)
	end
end

function relic_cursed_phoenix_down:OnIntervalThink()
	if self:GetParent().tombstoneEntity and self:GetParent().tombstoneEntity:IsNull() then self:GetParent().tombstoneEntity = nil end
	if not self:GetParent():IsAlive() and self:GetParent().tombstoneEntity and self:GetParent().tombstoneEntity:IsChanneling() then
		self:GetParent():SetBuyBackDisabledByReapersScythe( false )
	else
		self:GetParent():SetBuyBackDisabledByReapersScythe( true )
	end
end

function relic_cursed_phoenix_down:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE}
end

function relic_cursed_phoenix_down:GetModifierTotalDamageOutgoing_Percentage(params)
	if self:GetStackCount() == 1 then
		return -25
	end
end

function relic_cursed_phoenix_down:IsHidden()
	return self:GetStackCount() ~= 1
end

function relic_cursed_phoenix_down:IsPurgable()
	return false
end

function relic_cursed_phoenix_down:RemoveOnDeath()
	return false
end

function relic_cursed_phoenix_down:IsPermanent()
	return true
end

function relic_cursed_phoenix_down:AllowIllusionDuplicate()
	return true
end

function relic_cursed_phoenix_down:IsDebuff()
	return true
end
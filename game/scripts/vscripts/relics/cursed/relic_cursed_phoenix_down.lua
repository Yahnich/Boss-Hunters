relic_cursed_phoenix_down = class({})

function relic_cursed_phoenix_down:OnCreated()
	if IsServer() then
		self:OnIntervalThink()
		self:StartIntervalThink(0.33)
	end
end

function relic_cursed_phoenix_down:OnIntervalThink()
	if self:GetParent().tombstoneEntity and self:GetParent().tombstoneEntity:IsNull() then self:GetParent().tombstoneEntity = nil end
	PlayerResource:SetCustomBuybackCooldown(self:GetParent():GetPlayerID(), 0)
	PlayerResource:SetCustomBuybackCost(self:GetParent():GetPlayerID(), 0)
	if not self:GetParent():IsAlive() and self:GetParent().tombstoneEntity and self:GetParent().tombstoneEntity:IsChanneling() then
		self:GetParent():SetBuyBackDisabledByReapersScythe( false )
	else
		self:GetParent():SetBuyBackDisabledByReapersScythe( true )
	end
end

function relic_cursed_phoenix_down:IsHidden()
	return true
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

function relic_cursed_phoenix_down:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
relic_unique_mysterious_hourglass = class({})

function relic_unique_mysterious_hourglass:OnCreated()
	self:SetStackCount(3)
end

function relic_unique_mysterious_hourglass:IsHidden()
	return self:GetStackCount() == 0
end

function relic_unique_mysterious_hourglass:IsPurgable()
	return false
end

function relic_unique_mysterious_hourglass:RemoveOnDeath()
	return false
end

function relic_unique_mysterious_hourglass:IsPermanent()
	return true
end

function relic_unique_mysterious_hourglass:AllowIllusionDuplicate()
	return true
end
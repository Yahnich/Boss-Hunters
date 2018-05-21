relic_unique_mysterious_hourglass = class(relicBaseClass)

function relic_unique_mysterious_hourglass:OnCreated()
	self:SetStackCount(3)
end

function relic_unique_mysterious_hourglass:IsHidden()
	return self:GetStackCount() == 0
end
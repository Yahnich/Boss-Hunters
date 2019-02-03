relic_mysterious_hourglass = class(relicBaseClass)

function relic_mysterious_hourglass:OnCreated()
	self:SetStackCount(3)
end

function relic_mysterious_hourglass:IsHidden()
	return self:GetStackCount() == 0
end
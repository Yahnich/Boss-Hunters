relic_unique_ofuda = class(relicBaseClass)

function relic_unique_ofuda:OnCreated()
	self:SetStackCount(2)
end

function relic_unique_ofuda:IsHidden()
	return self:GetStackCount() == 0
end
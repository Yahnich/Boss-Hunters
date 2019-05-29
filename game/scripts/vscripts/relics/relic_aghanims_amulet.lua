relic_aghanims_amulet = class(relicBaseClass)

function relic_aghanims_amulet:OnCreated()
	if IsServer() then
		self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_item_ultimate_scepter_consumed", {})
	end
end
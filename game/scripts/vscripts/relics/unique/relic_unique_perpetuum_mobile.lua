relic_unique_perpetuum_mobile = class(relicBaseClass)

function relic_unique_perpetuum_mobile:DeclareFunctions()
	return {MODIFIER_EVENT_ON_SPENT_MANA}
end

function relic_unique_perpetuum_mobile:OnSpentMana(params)
	if params.unit == self:GetParent() then
		SendOverheadEventMessage(self:GetParent(), OVERHEAD_ALERT_MANA_ADD , self:GetParent(), 10, self:GetParent())
		self:GetParent():RestoreMana(10)
	end
end
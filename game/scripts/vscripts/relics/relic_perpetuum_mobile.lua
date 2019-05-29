relic_perpetuum_mobile = class(relicBaseClass)

function relic_perpetuum_mobile:DeclareFunctions()
	return {MODIFIER_EVENT_ON_SPENT_MANA}
end

function relic_perpetuum_mobile:OnSpentMana(params)
	if params.unit == self:GetParent() then
		self:GetParent():RestoreMana(10)
	end
end
relic_cursed_hushpuppy = class(relicBaseClass)

function relic_cursed_hushpuppy:OnIntervalThink()
	self:SetDuration(-1, true)
	self:StartIntervalThink(-1)
end

function relic_cursed_hushpuppy:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_START, MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function relic_cursed_hushpuppy:OnAbilityStart(params)
	if params.target == self:GetParent() and self:GetDuration() == -1 and params.unit:GetTeam() ~= params.target:GetTeam() then
		params.unit:RemoveModifierByName("modifier_status_immunity")
		params.unit:Silence(nil, self:GetParent(), 3)
		self:SetDuration(15.1, true)
		self:StartIntervalThink(15)
	end
end

function relic_cursed_hushpuppy:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() and self:GetDuration() == -1 then
		params.unit:RemoveModifierByName("modifier_status_immunity")
		params.unit:Silence(nil, self:GetParent(), 3)
		self:SetDuration(15.1, true)
		self:StartIntervalThink(15)
	end
end

function relic_cursed_hushpuppy:IsHidden()
	return false
end
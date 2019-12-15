relic_hushpuppy = class(relicBaseClass)

function relic_hushpuppy:OnIntervalThink()
	self:SetDuration(-1, true)
	self:StartIntervalThink(-1)
end

function relic_hushpuppy:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ABILITY_START, MODIFIER_EVENT_ON_ABILITY_FULLY_CAST}
end

function relic_hushpuppy:OnAbilityStart(params)
	if params.unit ~= self:GetParent() and self:GetDuration() == -1 and params.unit:GetTeam() ~= self:GetParent():GetTeam() and CalculateDistance( params.unit, self:GetParent() ) <= 450 then
		params.unit:RemoveModifierByName("modifier_status_immunity")
		params.unit:Silence(nil, params.unit, 6)
		self:SetDuration(15.1, true)
		self:StartIntervalThink(15)
	end
end

function relic_hushpuppy:OnAbilityFullyCast(params)
	if params.unit == self:GetParent() and self:GetDuration() == -1 and not self:GetParent():HasModifier("relic_ritual_candle") then
		params.unit:RemoveModifierByName("modifier_status_immunity")
		params.unit:Silence(nil, self:GetParent(), 3)
		self:SetDuration(15.1, true)
		self:StartIntervalThink(15)
	end
end

function relic_hushpuppy:IsHidden()
	return false
end
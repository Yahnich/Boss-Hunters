relic_rage_enhancer = class(relicBaseClass)

function relic_rage_enhancer:OnCreated()
	self:SetStackCount(0)
	self.internalcooldown = false
end

function relic_rage_enhancer:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK, MODIFIER_PROPERTY_EXTRA_STRENGTH_BONUS}
end

function relic_rage_enhancer:OnAttack(params)
	if params.target == self:GetParent() and not self.internalcooldown then
		self:AddIndependentStack(25, nil)
		params.target:CalculateStatBonus()
		self.internalcooldown = true
		Timers:CreateTimer(0.2, function() self.internalcooldown = false end)
	end
end

function relic_rage_enhancer:GetModifierExtraStrengthBonus()
	return self:GetStackCount()
end

function relic_rage_enhancer:IsHidden()
	return false
end
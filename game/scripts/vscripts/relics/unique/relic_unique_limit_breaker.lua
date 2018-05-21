relic_unique_limit_breaker = class(relicBaseClass)

function relic_unique_limit_breaker:OnCreated()
	self.batdecrease = self:GetParent():GetBaseAttackTime() * ( 7 / self:GetParent():GetAttackSpeed() )
	self:StartIntervalThink(0.33)
end

function relic_unique_limit_breaker:OnIntervalThink()
	self.batdecrease = 0
	self.batdecrease = self:GetParent():GetBaseAttackTime() * ( 1 - ( 7 / self:GetParent():GetAttackSpeed() ) )
end

function relic_unique_limit_breaker:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT}
end

function relic_unique_limit_breaker:GetBaseAttackTime_Bonus(params)
	if self:GetParent():GetAttackSpeed() > 7 then
		return self.batdecrease
	end
end
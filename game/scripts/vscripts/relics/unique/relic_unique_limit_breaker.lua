relic_unique_limit_breaker = class({})

function relic_unique_limit_breaker:OnCreated()
	self.batdecrease = self:GetParent():GetBaseAttackTime() * ( 7 / self:GetParent():GetAttackSpeed() )
	self:StartIntervalThink(0.33)
end

function relic_unique_limit_breaker:OnIntervalThink()
	self.batdecrease = 0
	self.batdecrease = self:GetParent():GetBaseAttackTime() * ( 7 / self:GetParent():GetAttackSpeed() )
end

function relic_unique_limit_breaker:DeclareFunctions()
	return {MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT}
end

function relic_unique_limit_breaker:GetModifierBaseAttackTimeConstant(params)
	if self:GetParent():GetAttackSpeed() > 7 then
		return self.batdecrease
	end
end 

function relic_unique_limit_breaker:IsHidden()
	return true
end

function relic_unique_limit_breaker:IsPurgable()
	return false
end

function relic_unique_limit_breaker:RemoveOnDeath()
	return false
end

function relic_unique_limit_breaker:IsPermanent()
	return true
end

function relic_unique_limit_breaker:AllowIllusionDuplicate()
	return true
end

function relic_unique_limit_breaker:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end



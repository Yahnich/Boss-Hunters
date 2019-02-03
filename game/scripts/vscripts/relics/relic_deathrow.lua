relic_deathrow = class(relicBaseClass)
function relic_deathrow:OnCreated()
	self.kills = 0
end

function relic_deathrow:DeclareFunctions()
	return {MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE, MODIFIER_EVENT_ON_DEATH}
end

function relic_deathrow:GetModifierPreAttack_CriticalStrike()
	if RollPercentage(20) then return 200 + self:GetStackCount() * 10 end
end

function relic_deathrow:OnDeath(params)
	if params.attacker == self:GetParent() and params.unit:IsRoundNecessary() then
		self.kills = self.kills + 1
		if self.kills >= math.ceil(self:GetStackCount() / 10) then
			self:IncrementStackCount()
			self.kills = 0
		end
	end
end

function relic_deathrow:IsHidden()
	return false
end
relic_deathrow = class(relicBaseClass)

function relic_deathrow:OnCreated()
	self.kills = 0
	self:OnRefresh()
end

function relic_deathrow:OnRefresh()
	if IsServer() then
		self:GetParent():HookInModifier("GetModifierCriticalDamage", self)
	end
end

function relic_deathrow:OnDestroy()
	if IsServer() then
		self:GetParent():HookOutModifier("GetModifierCriticalDamage", self)
	end
end

function relic_deathrow:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function relic_deathrow:GetModifierCriticalDamage()
	if self:RollPRNG(15) then return 200 + self:GetStackCount() * 10 end
end

function relic_deathrow:OnDeath(params)
	if params.attacker == self:GetParent() and params.unit:IsBoss() then
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
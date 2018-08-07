relic_unique_rotting_flesh = class(relicBaseClass)

function relic_unique_rotting_flesh:OnCreated()
	self:SetStackCount(1)
end

function relic_unique_rotting_flesh:OnIntervalThink()
	if not parent:IsAlive() then
		local origin = parent:GetOrigin()
		parent:RespawnHero(false, false)
		parent:SetOrigin(origin)
	end
	modifier:SetDuration(-1, true)
	modifier:SetIntervalThink(-1)
	modifier:SetStackCount(1)
end

function relic_unique_rotting_flesh:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function relic_unique_rotting_flesh:OnDeath(params)
	if params.unit == self:GetParent() then
		local modifier = self
		local parent = self:GetParent()
		modifier:SetDuration(40.1, true)
		self:StartIntervalThink(40)
		modifier:SetStackCount(0)
		
	end
end

function relic_unique_rotting_flesh:DestroyOnExpire()
	return false
end

function relic_unique_rotting_flesh:IsHidden()
	return self:GetStackCount() == 1
end
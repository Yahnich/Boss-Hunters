relic_unique_rotting_flesh = class(relicBaseClass)

function relic_unique_rotting_flesh:OnCreated()
	self:SetStackCount(1)
end

function relic_unique_rotting_flesh:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function relic_unique_rotting_flesh:OnDeath(params)
	if params.unit == self:GetParent() then
		local modifier = self
		local parent = self:GetParent()
		modifier:SetDuration(40.1, true)
		modifier:SetStackCount(0)
		local timer = 40
		Timers:CreateTimer(function()
			if not parent:IsAlive() then
				timer = timer - 1
				if timer > 0 then
					return 1
				else
					local origin = parent:GetOrigin()
					parent:RespawnHero(false, false)
					parent:SetOrigin(origin)
				end
			end
			modifier:SetDuration(-1, true)
		end)
	end
end

function relic_unique_rotting_flesh:DestroyOnExpire()
	return false
end

function relic_unique_rotting_flesh:IsHidden()
	return self:GetStackCount() == 1
end
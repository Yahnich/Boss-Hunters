relic_memory_alloy = class(relicBaseClass)

function relic_memory_alloy:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE }
end

function relic_memory_alloy:OnTakeDamage(params)
	if params.unit == self:GetParent() and not ( HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_HPLOSS) or HasBit(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) )  then
		local healticks = math.ceil(40 / 0.33)
		local healpTick = (params.damage * 1) / healticks

		local parent = self:GetParent()
		Timers:CreateTimer(0.33, function()
			healticks = healticks - 1
			parent:HealEvent(healpTick, nil, parent, true)
			if healticks > 0 then
				return 0.33
			end
		end)
	end
end

function relic_memory_alloy:IsHidden()
	return self:GetStackCount() == 0
end

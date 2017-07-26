modifier_generic_barrier = class({})

if IsServer() then
	function modifier_generic_barrier:OnCreated(kv)
		self.barrier = kv.barrier or 0
		if IsServer() then self:StartIntervalThink(0.5) end
	end

	function modifier_generic_barrier:OnRefresh(kv)
		self.barrier = (self.barrier or 0) + kv.barrier
		self.ModifierBarrier_Bonus = function() return self.barrier end
	end
	
	function modifier_generic_barrier:IsHidden(kv)
		return true
	end

	function modifier_generic_barrier:OnIntervalThink()
		if self.barrier <= 0 then self:Destroy() end
	end

	function modifier_generic_barrier:DeclareFunctions()
		local funcs = {
			MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		}
		return funcs
	end

	function modifier_generic_barrier:ModifierBarrier_Bonus()
		return (self.barrier or 0)
	end

	function modifier_generic_barrier:GetModifierIncomingDamage_Percentage(params)
		if params.damage < self:ModifierBarrier_Bonus() then
			self.barrier = (self:ModifierBarrier_Bonus() or 0) - params.damage
			self.ModifierBarrier_Bonus = function() return self.barrier end
			return -100
		elseif self:ModifierBarrier_Bonus() > 0 then
			self.barrier = 0
			local dmgRed = (params.damage / self:ModifierBarrier_Bonus()) * (-1)
			self.ModifierBarrier_Bonus = function() return self.barrier end
			return dmgRed
		else
			self:Destroy()
		end
	end
end
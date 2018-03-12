modifier_generic_barrier = class({})

function modifier_generic_barrier:IsHidden()
	return false
end

if IsServer() then
	function modifier_generic_barrier:OnCreated(kv)
		self.barrier = kv.barrier or 0
		self:StartIntervalThink(0.3)
		self.nfx = ParticleManager:CreateParticle("particles/items3_fx/lotus_orb_shield.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(self.nfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	end

	function modifier_generic_barrier:OnIntervalThink()
		self.barrier = math.max( 0, self.barrier - math.max( 1, self.barrier * self:ModifierBarrier_DegradeRate() ) )
		if self:ModifierBarrier_Bonus() <= 0 then self:Destroy() end
	end
	
	function modifier_generic_barrier:OnRefresh(kv)
		self.barrier = (self.barrier or 0) + kv.barrier
		self.ModifierBarrier_Bonus = function() return self.barrier end
		self.nfx = ParticleManager:CreateParticle("particles/items3_fx/lotus_orb_shield.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(self.nfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
	end

	function modifier_generic_barrier:OnRemoved()
		ParticleManager:DestroyParticle(self.nfx, false)
	end
	
	function modifier_generic_barrier:GetAttributes(kv)
		return MODIFIER_ATTRIBUTE_MULTIPLE
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
	
	function modifier_generic_barrier:ModifierBarrier_DegradeRate()
		return 0.01
	end

	function modifier_generic_barrier:GetModifierIncomingDamage_Percentage(params)
		if params.damage < self:ModifierBarrier_Bonus() then
			self.barrier = (self:ModifierBarrier_Bonus() or 0) - params.damage
			self.ModifierBarrier_Bonus = function() return self.barrier end
			return -100
		elseif self:ModifierBarrier_Bonus() > 0 then
			local dmgRed = (params.damage / self:ModifierBarrier_Bonus()) * (-1)
			self.barrier = 0
			return dmgRed
		else
			self:Destroy()
		end
	end
end
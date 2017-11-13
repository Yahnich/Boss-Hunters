modifier_dazed_generic = modifier_dazed_generic or class({})

modifier_dazed_generic = class({})

function modifier_dazed_generic:OnCreated()
	if IsServer() then
		self.daze = ParticleManager:CreateParticle("particles/generic_dazed.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
		self:AddParticle(self.daze,false, false, 0, false, true)
		self:StartIntervalThink(0.2)
	end
end

function modifier_dazed_generic:OnDestroy()
	if IsServer() then
		ParticleManager:DestroyParticle(self.daze, true)
		ParticleManager:ReleaseParticleIndex(self.daze)
	end
end

function modifier_dazed_generic:OnIntervalThink()
	if RollPercentage(12) then
		self:GetParent():Stop()
		self:GetParent():Interrupt()
	end
end


function modifier_dazed_generic:IsDaze()
	return true
end

function modifier_dazed_generic:IsPurgable()
	return true
end
modifier_charm_generic = class({})
LinkLuaModifier("modifier_charm_generic", "libraries/modifiers/modifier_charm_generic", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_charm_generic:OnCreated()
		local nfx = ParticleManager:CreateParticle("particles/generic/charm_debuff/charm_generic_overhead.vpcf", PATTACH_POINT_FOLLOW, self:GetParent())
					ParticleManager:SetParticleControlEnt(nfx, 0, self:GetParent(), PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)
					ParticleManager:SetParticleControlEnt(nfx, 1, self:GetParent(), PATTACH_OVERHEAD_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)

		self:AttachEffect(nfx)
		
		self:StartIntervalThink(0.5)
	end
	
	function modifier_charm_generic:OnIntervalThink()
		if self:GetParent():HasModifier("modifier_fear_generic") then return end
		self:GetParent():MoveToPosition( self:GetCaster():GetAbsOrigin() )
	end
end

function modifier_charm_generic:CheckState()
	return {[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_SILENCED] = true,
			[MODIFIER_STATE_TAUNTED ] = true,
			[MODIFIER_STATE_PROVIDES_VISION] = true,
			}
end
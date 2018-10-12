modifier_root_generic = class({})

if IsServer() then
	function modifier_root_generic:OnCreated(kv)
		if kv.delay == nil or toboolean(kv.delay) == true then
			self.delay = true
			self:GetAbility():StartDelayedCooldown(self:GetRemainingTime(), false)
		end
	end
	
	function modifier_root_generic:OnDestroy()
		if self.delay then self:GetAbility():EndDelayedCooldown() end
	end
end

function modifier_root_generic:GetEffectName()
	return "particles/units/heroes/hero_dark_willow/dark_willow_bramble_root.vpcf"
end

function modifier_root_generic:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_root_generic:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_root_generic:CheckState()
	local state = { [MODIFIER_STATE_ROOTED] = true}
	return state
end

function modifier_root_generic:IsPurgable()
	return true
end

function modifier_root_generic:IsDebuff()
	return true
end
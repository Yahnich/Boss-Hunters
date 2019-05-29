modifier_root_generic = class({})

if IsServer() then
	function modifier_root_generic:OnCreated(kv)
		if kv.delay ~= nil or toboolean(kv.delay) == true then
			self.delay = true
			self:GetAbility():StartDelayedCooldown(self:GetRemainingTime(), false)
		end
	end
	
	function modifier_root_generic:OnDestroy()
		if self.delay then self:GetAbility():EndDelayedCooldown() end
	end
end

function modifier_root_generic:GetEffectName()
	return "particles/units/heroes/hero_oracle/oracle_fortune_purge_root_pnt.vpcf"
end

function modifier_root_generic:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end


function modifier_root_generic:CheckState()
	local state = { [MODIFIER_STATE_ROOTED] = true,
					[MODIFIER_STATE_INVISIBLE] = false}
	return state
end

function modifier_root_generic:IsPurgable()
	return true
end

function modifier_root_generic:IsDebuff()
	return true
end
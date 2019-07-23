modifier_fear_generic = class({})
LinkLuaModifier("modifier_fear_generic", "libraries/modifiers/modifier_fear_generic", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function modifier_fear_generic:OnCreated()
		self:StartIntervalThink(1)
	end
	
	function modifier_fear_generic:OnIntervalThink()
		local direction = CalculateDirection(self:GetParent(), self:GetCaster())
		local oldPos = self:GetParent():GetAbsOrigin()
		local newPos = oldPos + direction * self:GetParent():GetIdealSpeed() * 0.5
		
		if not GridNav:CanFindPath(oldPos, newPos) then
			local iteration = 100
			while not GridNav:CanFindPath(oldPos, newPos) and iteration > 0 do
				newPos = self:GetParent():GetAbsOrigin() + RandomVector(self:GetParent():GetIdealSpeed() * 0.5)
				iteration = iteration - 1
			end
		end
		self:GetParent():MoveToPosition(newPos)
	end
end

function modifier_fear_generic:GetEffectName()
	return "particles/units/heroes/hero_lone_druid/lone_druid_savage_roar_debuff.vpcf"
end

function modifier_fear_generic:GetStatusEffectName()
	return "particles/status_fx/status_effect_lone_druid_savage_roar.vpcf"
end

function modifier_fear_generic:StatusEffectPriority()
	return 10
end

function modifier_fear_generic:CheckState()
	return {[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
			[MODIFIER_STATE_DISARMED] = true,
			[MODIFIER_STATE_SILENCED] = true,
			[MODIFIER_STATE_PROVIDES_VISION] = true,
			}
end
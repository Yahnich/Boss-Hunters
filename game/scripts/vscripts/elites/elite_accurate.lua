elite_accurate = class({})

function elite_accurate:GetIntrinsicModifierName()
	return "modifier_elite_accurate"
end

modifier_elite_accurate = class(relicBaseClass)
LinkLuaModifier("modifier_elite_accurate", "elites/elite_accurate", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_accurate:OnCreated()
	if IsServer() then
		
	end
end

function modifier_elite_accurate:CheckState()
	return {[MODIFIER_STATE_CANNOT_MISS] = not self:GetParent():PassivesDisabled()}
end

function modifier_elite_accurate:GetPriority()
	return MODIFIER_PRIORITY_LOW
end
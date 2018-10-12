elite_graverobber = class({})

function elite_graverobber:GetIntrinsicModifierName()
	return "modifier_elite_graverobber"
end

modifier_elite_graverobber = class({})
LinkLuaModifier("modifier_elite_graverobber", "elites/elite_graverobber", LUA_MODIFIER_MOTION_NONE)

function modifier_elite_graverobber:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_elite_graverobber:OnDeath(params)
	if params.attacker == self:GetParent() then
		params.unit.tombstoneDisabled = true
	end
end
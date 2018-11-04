modifier_boss_ascension = class({})

function modifier_boss_ascension:IsHidden()
	return true
end

function modifier_boss_ascension:OnCreated()
	if IsServer() then
		self:SetStackCount( RoundManager:GetAscensions() )
	end
end

function modifier_boss_ascension:CheckState()
	return {[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = self:GetStackCount() >= 4 }
end

function modifier_boss_ascension:GetPriority()
	return MODIFIER_PRIORITY_LOW
end

function modifier_boss_ascension:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
	}
	return funcs
end
--------------------------------------------------------------------------------
function modifier_boss_ascension:GetModifierStatusResistanceStacking( params )
	return math.max( 0, math.min(75, (self:GetStackCount() - 1) * 25) )
end

function modifier_boss_ascension:GetModifierMoveSpeed_AbsoluteMin( params )
	if self:GetStackCount() >= 4 then
		return 550
	end
end

function modifier_boss_ascension:IsPurgable()
	return false
end
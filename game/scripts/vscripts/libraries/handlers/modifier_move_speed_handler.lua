modifier_move_speed_handler = class({})
	
function modifier_move_speed_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE}
end

function modifier_move_speed_handler:GetModifierMoveSpeed_Absolute()
	return self:GetStackCount()
end

function modifier_move_speed_handler:IsHidden()
	return true
end

function modifier_move_speed_handler:IsPurgable()
	return false
end

function modifier_move_speed_handler:RemoveOnDeath()
	return false
end

function modifier_move_speed_handler:IsPermanent()
	return true
end

function modifier_move_speed_handler:AllowIllusionDuplicate()
	return true
end

function modifier_move_speed_handler:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
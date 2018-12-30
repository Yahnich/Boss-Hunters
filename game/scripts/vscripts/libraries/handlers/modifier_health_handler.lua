modifier_health_handler = class({})
	
function modifier_health_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS}
end

function modifier_health_handler:GetModifierExtraHealthBonus()
	local health = self:GetStackCount()
	if health ~= 0 then
		-- check sign
		if health % 10 == 0 then
			return math.floor( health / 10 )
		else
			return math.floor( health / 10 ) * (-1)
		end
	end
end

function modifier_health_handler:IsHidden()
	return true
end

function modifier_health_handler:IsPurgable()
	return false
end

function modifier_health_handler:RemoveOnDeath()
	return false
end

function modifier_health_handler:IsPermanent()
	return true
end

function modifier_health_handler:AllowIllusionDuplicate()
	return true
end

function modifier_health_handler:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
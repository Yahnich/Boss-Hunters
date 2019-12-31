modifier_health_handler = class({})
	
function modifier_health_handler:OnStackCountChanged(oldStacks)
	local health = self:GetStackCount()
	local parent = self:GetParent()
	if health % 10 == 0 then
		self.health = math.floor( health / 10 )
	else
		self.health = math.floor( health / 10 ) * (-1)
	end
end

function modifier_health_handler:DeclareFunctions()
	return {MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS}
end

function modifier_health_handler:GetModifierExtraHealthBonus()
	return self.health or 0
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
modifier_accuracy_handler = class({})

function modifier_accuracy_handler:OnCreated()
	self:SetStackCount(0)
end
	
function modifier_accuracy_handler:CheckState()
	if self.state == true then
		return {[MODIFIER_STATE_CANNOT_MISS] = true }
	end
end

function modifier_accuracy_handler:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_START}
end

function modifier_accuracy_handler:OnAttackStart(params)
	if not params.attacker == self:GetParent() then return end
	self.state = false
	for _, modifier in ipairs( params.attacker:FindAllModifiers() ) do
		if modifier ~= self and modifier.GetAccuracy then
			local roll = modifier:GetAccuracy(params) 
			if roll and not self.state then
				self.state = self.state or roll == 100 or modifier:RollPRNG( roll )
			end
		end
	end
end

function modifier_accuracy_handler:IsHidden()
	return true
end

function modifier_accuracy_handler:IsPurgable()
	return false
end

function modifier_accuracy_handler:RemoveOnDeath()
	return false
end

function modifier_accuracy_handler:IsPermanent()
	return true
end

function modifier_accuracy_handler:AllowIllusionDuplicate()
	return true
end

function modifier_accuracy_handler:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end
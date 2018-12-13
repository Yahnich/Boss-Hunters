modifier_accuracy_handler = class({})


function modifier_accuracy_handler:OnCreated()
	self:SetStackCount(1)
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

if IsServer() then
	function modifier_accuracy_handler:OnIntervalThink()
		local stacks = 1
		for _, modifier in ipairs( self:GetParent():FindAllModifiers() ) do
			if modifier.GetAccuracy then
				local roll = modifier:GetAccuracy(params) 
				if roll then
					stacks = stacks * (1 - roll / 100)
				end
			end
		end
		local accuracy = (1 - stacks) * 100
		self:SetStackCount(accuracy)
	end
end
	
function modifier_accuracy_handler:CheckState()
	return {[MODIFIER_STATE_CANNOT_MISS] = self.state }
end

function modifier_accuracy_handler:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_START}
end

function modifier_accuracy_handler:OnAttackStart(params)
	if not params.attacker == self:GetParent() then return end
	self.state = false
	for _, modifier in ipairs( self:GetParent():FindAllModifiers() ) do
		if modifier ~= self and modifier.GetAccuracy then
			local roll = modifier:GetAccuracy(params) 
			if roll then
				self.state = self.state or modifier:RollPRNG( roll )
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